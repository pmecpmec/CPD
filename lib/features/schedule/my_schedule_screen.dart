import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../shared/formulier_velden.dart';
import '../events/event_detail_screen.dart';
import 'my_schedule_controller.dart';
import 'rooster_lijst.dart';

/// FR-14: alle events en matches van alle teams van de gebruiker.
class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MyScheduleController>().laad(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MyScheduleController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: RefreshIndicator(
        onRefresh: controller.laad,
        child: InhoudBegrenzer(
          maxBreedte: 720,
          child: _Inhoud(controller: controller),
        ),
      ),
    );
  }
}

class _Inhoud extends StatelessWidget {
  const _Inhoud({required this.controller});

  final MyScheduleController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.laadt &&
        controller.verdeling.isLeeg &&
        !controller.isLeegDoorFilter) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.foutmelding != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Foutmelding(controller.foutmelding!),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: controller.laad,
            icon: const Icon(Icons.refresh),
            label: const Text('Opnieuw proberen'),
          ),
        ],
      );
    }

    if (controller.isLeeg) {
      return const LeegRooster(
        titel: 'Er staat nog niets in je agenda',
        uitleg:
            'Events en matches van al je teams komen hier samen. Een match '
            'waarbij je via twee teams betrokken bent, telt maar één keer.',
      );
    }

    final toonFilter = controller.eigenTeams.length >= 2;
    final lijst = controller.isLeegDoorFilter
        ? const _LeegDoorFilter()
        : RoosterLijst(
            verdeling: controller.verdeling,
            onOpenEvent: (event) => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event),
              ),
            ),
            toonTeamNamen: (_) => true,
          );

    if (!toonFilter) return lijst;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TeamFilterRij(controller: controller),
        Expanded(child: lijst),
      ],
    );
  }
}

/// Horizontaal scrollbare chips, één per team. Alleen bij twee of meer teams.
class _TeamFilterRij extends StatelessWidget {
  const _TeamFilterRij({required this.controller});

  final MyScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          for (final team in controller.eigenTeams) ...[
            FilterChip(
              label: Text(team.name),
              selected: controller.gekozenTeamIds.contains(team.id),
              onSelected: (_) => controller.wisselTeam(team.id),
            ),
            const SizedBox(width: 8),
          ],
          if (controller.filterActief)
            TextButton(
              onPressed: controller.wisFilter,
              child: const Text('Alles tonen'),
            ),
        ],
      ),
    );
  }
}

/// Lege staat die hoort bij een filter zonder resultaat, niet bij een lege
/// agenda.
class _LeegDoorFilter extends StatelessWidget {
  const _LeegDoorFilter();

  @override
  Widget build(BuildContext context) {
    final tekst = Theme.of(context).textTheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Text(
          'Geen afspraken voor de gekozen teams.',
          textAlign: TextAlign.center,
          style: tekst.bodyMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => context.read<MyScheduleController>().wisFilter(),
            child: const Text('Alles tonen'),
          ),
        ),
      ],
    );
  }
}
