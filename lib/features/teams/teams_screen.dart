import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../shared/formulier_velden.dart';
import '../auth/auth_controller.dart';
import 'teams_controller.dart';

/// FR-05 — overzicht van de teams waar de gebruiker lid van is.
class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  static const routeNaam = '/teams';

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  @override
  void initState() {
    super.initState();
    // Na de eerste opbouw van het scherm, zodat notifyListeners geen build
    // onderbreekt die nog bezig is.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TeamsController>().laad(),
    );
  }

  Future<void> _nieuwTeam() async {
    final gegevens = await showDialog<({String naam, String beschrijving})>(
      context: context,
      builder: (_) => const _NieuwTeamDialoog(),
    );
    if (gegevens == null || !mounted) return;

    final controller = context.read<TeamsController>();
    final gelukt = await controller.maakTeam(
      naam: gegevens.naam,
      beschrijving: gegevens.beschrijving,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          gelukt
              ? 'Team "${gegevens.naam}" aangemaakt.'
              : controller.foutmelding ??
                    'Het team kon niet worden aangemaakt.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = context.watch<TeamsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn teams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Uitloggen',
            onPressed: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nieuwTeam,
        icon: const Icon(Icons.add),
        label: const Text('Nieuw team'),
      ),
      body: RefreshIndicator(
        onRefresh: teams.laad,
        child: InhoudBegrenzer(
          maxBreedte: 720,
          child: _Inhoud(controller: teams),
        ),
      ),
    );
  }
}

class _Inhoud extends StatelessWidget {
  const _Inhoud({required this.controller});

  final TeamsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.laadt && controller.teams.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.foutmelding != null && controller.teams.isEmpty) {
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
            Icons.group_add_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Je zit nog in geen enkel team',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Maak er zelf een aan, of laat je toevoegen door een teambeheerder.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      itemCount: controller.teams.length,
      itemBuilder: (context, i) {
        final team = controller.teams[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                team.name.isEmpty
                    ? '?'
                    : team.name.substring(0, 1).toUpperCase(),
              ),
            ),
            title: Text(team.name),
            subtitle: team.description.isEmpty ? null : Text(team.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Teamdetail volgt in sprint 2 (FR-06 tot en met FR-08).
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teamdetail volgt nog.')),
              );
            },
          ),
        );
      },
    );
  }
}

class _NieuwTeamDialoog extends StatefulWidget {
  const _NieuwTeamDialoog();

  @override
  State<_NieuwTeamDialoog> createState() => _NieuwTeamDialoogState();
}

class _NieuwTeamDialoogState extends State<_NieuwTeamDialoog> {
  final _formSleutel = GlobalKey<FormState>();
  final _naam = TextEditingController();
  final _beschrijving = TextEditingController();

  @override
  void dispose() {
    _naam.dispose();
    _beschrijving.dispose();
    super.dispose();
  }

  void _bevestig() {
    if (!_formSleutel.currentState!.validate()) return;
    Navigator.of(
      context,
    ).pop((naam: _naam.text.trim(), beschrijving: _beschrijving.text.trim()));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nieuw team'),
    content: Form(
      key: _formSleutel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _naam,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Naam'),
            validator: (waarde) => (waarde?.trim().isEmpty ?? true)
                ? 'Vul een teamnaam in.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _beschrijving,
            decoration: const InputDecoration(labelText: 'Beschrijving'),
            maxLines: 2,
            onFieldSubmitted: (_) => _bevestig(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuleren'),
      ),
      FilledButton(onPressed: _bevestig, child: const Text('Aanmaken')),
    ],
  );
}
