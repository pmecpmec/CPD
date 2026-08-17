import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../shared/formulier_velden.dart';
import '../events/event_detail_screen.dart';
import 'rooster.dart';
import 'rooster_lijst.dart';
import 'team_schedule_controller.dart';

/// FR-13: alle events en matches van één team, op tijd gesorteerd.
class TeamScheduleScreen extends StatefulWidget {
  const TeamScheduleScreen({super.key, required this.teamNaam});

  final String teamNaam;

  /// Opent het rooster van [teamId]. De controller wordt hier gemaakt omdat hij
  /// een team-id nodig heeft en dus niet in de vaste providers van `main.dart`
  /// past.
  static Future<void> open(
    BuildContext context, {
    required int teamId,
    required String teamNaam,
  }) {
    final events = context.read<EventRepository>();
    final matches = context.read<MatchRepository>();

    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => TeamScheduleController(
            eventRepository: events,
            matchRepository: matches,
            teamId: teamId,
          ),
          child: TeamScheduleScreen(teamNaam: teamNaam),
        ),
      ),
    );
  }

  @override
  State<TeamScheduleScreen> createState() => _TeamScheduleScreenState();
}

class _TeamScheduleScreenState extends State<TeamScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // Na de eerste opbouw, zodat notifyListeners geen lopende build onderbreekt.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TeamScheduleController>().laad(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeamScheduleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teamrooster'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.teamNaam,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ),
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

  final TeamScheduleController controller;

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
        titel: 'Er staat nog niets in dit rooster',
        uitleg:
            'Zodra een beheerder een event of een match aanmaakt, verschijnt '
            'die hier. Verleden en toekomst staan dan onder elkaar.',
      );
    }

    return RoosterLijst(
      verdeling: controller.verdeling,
      onOpenEvent: (event) => Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      // In het teamrooster kijkt de gebruiker naar één team; de teamnaam staat
      // al in de kop en hoeft niet bij elke regel (FR-13). Bij een match zegt
      // hij wel iets: dan gaat het om de tegenstander.
      toonTeamNamen: (item) => item.soort == RoosterSoort.match,
    );
  }
}
