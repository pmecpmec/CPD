import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/team_repository.dart';
import '../../shared/formulier_velden.dart';
import '../events/event_form_screen.dart';
import 'qr_invite_dialog.dart';
import 'team_detail_controller.dart';

/// FR-06, FR-07, FR-08 — één team met zijn leden.
///
/// Wat de gebruiker ziet en mag hangt af van [TeamDetailController]: een
/// niet-lid krijgt alleen naam en omschrijving, een lid ziet de ledenlijst en
/// kan vertrekken, en de beheerder kan leden verwijderen en het team opheffen.
class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({super.key});

  /// Opent het detailscherm en geeft terug wat er met het team is gebeurd,
  /// of `null` wanneer de gebruiker alleen heeft gekeken.
  ///
  /// De controller wordt hier gemaakt, omdat hij een team-id nodig heeft en
  /// dus niet in de vaste providers van `main.dart` past.
  static Future<TeamDetailUitkomst?> open(BuildContext context, Team team) {
    final teams = context.read<TeamRepository>();
    final auth = context.read<AuthRepository>();

    return Navigator.of(context).push<TeamDetailUitkomst>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => TeamDetailController(
            teamRepository: teams,
            authRepository: auth,
            teamId: team.id,
            bekendTeam: team,
          ),
          child: const TeamDetailScreen(),
        ),
      ),
    );
  }

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Na de eerste opbouw, zodat notifyListeners geen lopende build onderbreekt.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TeamDetailController>().laad(),
    );
  }

  /// Voert een actie uit die het team verandert en sluit het scherm bij succes.
  Future<void> _rondAf(
    Future<bool> Function() actie,
    TeamDetailUitkomst uitkomst,
  ) async {
    final controller = context.read<TeamDetailController>();
    final gelukt = await actie();
    if (!mounted) return;

    if (gelukt) {
      Navigator.of(context).pop(uitkomst);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.foutmelding ?? 'De actie kon niet worden uitgevoerd.',
        ),
      ),
    );
  }

  Future<void> _verlaatTeam() async {
    final controller = context.read<TeamDetailController>();
    final bevestigd = await _vraagBevestiging(
      context,
      titel: 'Team verlaten?',
      tekst:
          'Je verlaat "${controller.naam}". Je ziet het team en de bijbehorende '
          'agenda daarna niet meer. Een beheerder kan je opnieuw toevoegen.',
      knop: 'Verlaten',
    );
    if (!bevestigd || !mounted) return;
    await _rondAf(controller.verlaatTeam, TeamDetailUitkomst.verlaten);
  }

  Future<void> _verwijderTeam() async {
    final controller = context.read<TeamDetailController>();
    final bevestigd = await _vraagBevestiging(
      context,
      titel: 'Team verwijderen?',
      tekst:
          '"${controller.naam}" wordt voor alle leden verwijderd, met de '
          'geplande events erbij. Dit kun je niet ongedaan maken.',
      knop: 'Verwijderen',
      destructief: true,
    );
    if (!bevestigd || !mounted) return;
    await _rondAf(controller.verwijderTeam, TeamDetailUitkomst.verwijderd);
  }

  /// Opent het formulier voor een nieuw event van dit team (FR-11).
  Future<void> _nieuwEvent() async {
    final event = await EventFormScreen.open(
      context,
      teamId: context.read<TeamDetailController>().teamId,
    );
    if (event == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event "${event.title}" aangemaakt.')),
    );
  }

  Future<void> _verwijderLid(User lid) async {
    final controller = context.read<TeamDetailController>();
    final bevestigd = await _vraagBevestiging(
      context,
      titel: 'Lid verwijderen?',
      tekst:
          '${lid.name} wordt uit "${controller.naam}" verwijderd en ziet het '
          'team daarna niet meer.',
      knop: 'Verwijderen',
      destructief: true,
    );
    if (!bevestigd || !mounted) return;

    final gelukt = await controller.verwijderLid(lid.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          gelukt
              ? '${lid.name} is uit het team verwijderd.'
              : controller.foutmelding ?? 'Het lid kon niet worden verwijderd.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeamDetailController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.naam.isEmpty ? 'Team' : controller.naam),
      ),
      body: RefreshIndicator(
        onRefresh: controller.laad,
        child: InhoudBegrenzer(
          maxBreedte: 720,
          child: _Inhoud(
            controller: controller,
            onVerlaten: _verlaatTeam,
            onVerwijderen: _verwijderTeam,
            onNieuwEvent: _nieuwEvent,
            onLidVerwijderen: _verwijderLid,
          ),
        ),
      ),
    );
  }
}

class _Inhoud extends StatelessWidget {
  const _Inhoud({
    required this.controller,
    required this.onVerlaten,
    required this.onVerwijderen,
    required this.onNieuwEvent,
    required this.onLidVerwijderen,
  });

  final TeamDetailController controller;
  final VoidCallback onVerlaten;
  final VoidCallback onVerwijderen;
  final VoidCallback onNieuwEvent;
  final void Function(User lid) onLidVerwijderen;

  @override
  Widget build(BuildContext context) {
    if (controller.laadt && controller.team == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.foutmelding != null && controller.team == null) {
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _Kop(controller: controller),
        const SizedBox(height: 24),
        if (controller.isLid) ...[
          _Ledenlijst(controller: controller, onVerwijderen: onLidVerwijderen),
          const SizedBox(height: 24),
          _Acties(
            controller: controller,
            onVerlaten: onVerlaten,
            onVerwijderen: onVerwijderen,
            onNieuwEvent: onNieuwEvent,
          ),
        ] else
          const _PrivacyMelding(),
      ],
    );
  }
}

class _Kop extends StatelessWidget {
  const _Kop({required this.controller});

  final TeamDetailController controller;

  @override
  Widget build(BuildContext context) {
    final tekst = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(controller.naam, style: tekst.headlineSmall),
        const SizedBox(height: 8),
        Text(
          controller.omschrijving.isEmpty
              ? 'Dit team heeft geen omschrijving.'
              : controller.omschrijving,
          style: tekst.bodyLarge,
        ),
        if (controller.isBeheerder) ...[
          const SizedBox(height: 12),
          const Chip(
            avatar: Icon(Icons.shield_outlined, size: 18),
            label: Text('Je bent beheerder'),
          ),
        ],
      ],
    );
  }
}

/// Wat een niet-lid te zien krijgt in plaats van de ledenlijst (FR-06).
class _PrivacyMelding extends StatelessWidget {
  const _PrivacyMelding();

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;

    return Card(
      color: schema.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, color: schema.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Je bent geen lid van dit team. Alleen de naam en de '
                'omschrijving zijn zichtbaar. Laat je door een beheerder '
                'toevoegen om de leden en de agenda te zien.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ledenlijst extends StatelessWidget {
  const _Ledenlijst({required this.controller, required this.onVerwijderen});

  final TeamDetailController controller;
  final void Function(User lid) onVerwijderen;

  @override
  Widget build(BuildContext context) {
    final leden = controller.leden;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leden (${leden.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final lid in leden)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  lid.name.isEmpty
                      ? '?'
                      : lid.name.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Text(lid.name),
              subtitle: controller.isBeheerderVan(lid)
                  ? const Text('Beheerder')
                  : (controller.isJezelf(lid) ? const Text('Jij') : null),
              // De beheerder kan iedereen verwijderen behalve zichzelf; daarvoor
              // bestaat "Team verwijderen" (FR-07, FR-08).
              trailing:
                  controller.isBeheerder && !controller.isBeheerderVan(lid)
                  ? IconButton(
                      icon: const Icon(Icons.person_remove_outlined),
                      tooltip: '${lid.name} verwijderen',
                      onPressed: controller.bezig
                          ? null
                          : () => onVerwijderen(lid),
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

class _Acties extends StatelessWidget {
  const _Acties({
    required this.controller,
    required this.onVerlaten,
    required this.onVerwijderen,
    required this.onNieuwEvent,
  });

  final TeamDetailController controller;
  final VoidCallback onVerlaten;
  final VoidCallback onVerwijderen;
  final VoidCallback onNieuwEvent;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    final bezig = controller.bezig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.isBeheerder) ...[
          FilledButton.icon(
            // Alleen de beheerder maakt events aan (FR-11).
            onPressed: bezig ? null : onNieuwEvent,
            icon: const Icon(Icons.event_outlined),
            label: const Text('Event aanmaken'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            // Alleen de beheerder nodigt uit (FR-09); de dialoog toont de code
            // en heeft daarvoor niets meer nodig dan het team-id.
            onPressed: bezig
                ? null
                : () => QrInviteDialog.toon(
                    context,
                    teamId: controller.teamId,
                    teamNaam: controller.naam,
                  ),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('QR-uitnodiging'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: bezig ? null : onVerwijderen,
            style: OutlinedButton.styleFrom(foregroundColor: schema.error),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Team verwijderen'),
          ),
        ],
        // Een beheerder kan niet vertrekken: die kan het team alleen
        // verwijderen (FR-07).
        if (controller.magVertrekken)
          OutlinedButton.icon(
            onPressed: bezig ? null : onVerlaten,
            icon: const Icon(Icons.logout),
            label: const Text('Team verlaten'),
          ),
      ],
    );
  }
}

/// Vraagt om bevestiging voor een actie die niet zomaar terug te draaien is.
Future<bool> _vraagBevestiging(
  BuildContext context, {
  required String titel,
  required String tekst,
  required String knop,
  bool destructief = false,
}) async {
  final schema = Theme.of(context).colorScheme;

  final antwoord = await showDialog<bool>(
    context: context,
    builder: (dialoogContext) => AlertDialog(
      title: Text(titel),
      content: Text(tekst),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialoogContext).pop(false),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialoogContext).pop(true),
          style: destructief
              ? FilledButton.styleFrom(
                  backgroundColor: schema.error,
                  foregroundColor: schema.onError,
                )
              : null,
          child: Text(knop),
        ),
      ],
    ),
  );

  return antwoord ?? false;
}
