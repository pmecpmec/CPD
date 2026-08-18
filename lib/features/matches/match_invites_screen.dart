import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/team_repository.dart';
import '../../shared/formulier_velden.dart';
import 'invite_overgangen.dart';
import 'match_form_screen.dart';
import 'match_invites_controller.dart';

/// FR-16 — ontvangen match-uitnodigingen beantwoorden.
class MatchInvitesScreen extends StatefulWidget {
  const MatchInvitesScreen({super.key});

  static Future<void> open(BuildContext context) {
    final matches = context.read<MatchRepository>();
    final teams = context.read<TeamRepository>();
    final auth = context.read<AuthRepository>();

    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MatchInvitesController(
            matchRepository: matches,
            teamRepository: teams,
            authRepository: auth,
          ),
          child: const MatchInvitesScreen(),
        ),
      ),
    );
  }

  @override
  State<MatchInvitesScreen> createState() => _MatchInvitesScreenState();
}

class _MatchInvitesScreenState extends State<MatchInvitesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MatchInvitesController>().laad(),
    );
  }

  Future<void> _nieuwMatch() async {
    final match = await MatchFormScreen.open(context);
    if (match == null || !mounted) return;
    await context.read<MatchInvitesController>().laad();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Match "${match.title}" aangemaakt.')),
    );
  }

  Future<void> _beantwoord(OntvangenUitnodiging item, InviteStatus naar) async {
    final controller = context.read<MatchInvitesController>();
    final gelukt = await controller.beantwoord(item, naar);
    if (!mounted || gelukt) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.foutmelding ?? const ServerException().bericht,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MatchInvitesController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      floatingActionButton: controller.magMatchAanmaken
          ? FloatingActionButton.extended(
              onPressed: controller.bezig ? null : _nieuwMatch,
              icon: const Icon(Icons.sports_outlined),
              label: const Text('Nieuwe match'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: controller.laad,
        child: InhoudBegrenzer(
          maxBreedte: 720,
          child: _Inhoud(controller: controller, onBeantwoord: _beantwoord),
        ),
      ),
    );
  }
}

class _Inhoud extends StatelessWidget {
  const _Inhoud({required this.controller, required this.onBeantwoord});

  final MatchInvitesController controller;
  final void Function(OntvangenUitnodiging item, InviteStatus naar)
  onBeantwoord;

  @override
  Widget build(BuildContext context) {
    if (controller.laadt && controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.foutmelding != null && controller.items.isEmpty) {
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
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 64),
          Icon(
            Icons.sports_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Geen uitnodigingen',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Als een ander team je uitnodigt voor een match, verschijnt dat '
            'hier. Een beheerder kan zelf een match aanmaken.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      itemCount: controller.items.length,
      itemBuilder: (context, i) {
        final item = controller.items[i];
        return _UitnodigingTegel(
          item: item,
          bezig: controller.bezig,
          onBeantwoord: onBeantwoord,
        );
      },
    );
  }
}

class _UitnodigingTegel extends StatelessWidget {
  const _UitnodigingTegel({
    required this.item,
    required this.bezig,
    required this.onBeantwoord,
  });

  final OntvangenUitnodiging item;
  final bool bezig;
  final void Function(OntvangenUitnodiging item, InviteStatus naar)
  onBeantwoord;

  @override
  Widget build(BuildContext context) {
    final overgangen = item.overgangen;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.titel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(item.invite.status.label),
            if (overgangen.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final naar in overgangen)
                    naar == InviteStatus.declined ||
                            naar == InviteStatus.canceled
                        ? OutlinedButton(
                            onPressed: bezig
                                ? null
                                : () => onBeantwoord(item, naar),
                            child: Text(inviteOvergangKnop(naar)),
                          )
                        : FilledButton(
                            onPressed: bezig
                                ? null
                                : () => onBeantwoord(item, naar),
                            child: Text(inviteOvergangKnop(naar)),
                          ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
