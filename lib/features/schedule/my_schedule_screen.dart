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
    if (controller.laadt && controller.verdeling.isLeeg) {
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

    return RoosterLijst(
      verdeling: controller.verdeling,
      onOpenEvent: (event) => Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      toonTeamNamen: (_) => true,
    );
  }
}
