import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../../shared/datum_tekst.dart';
import 'rooster.dart';

/// Lege staat van een rooster, met uitleg waarom er niets staat (FR-13).
///
/// De inhoud is een [ListView] zodat de gebruiker nog steeds naar beneden kan
/// trekken om te verversen.
class LeegRooster extends StatelessWidget {
  const LeegRooster({super.key, required this.titel, required this.uitleg});

  final String titel;
  final String uitleg;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    final tekst = Theme.of(context).textTheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 64),
        Icon(Icons.event_busy_outlined, size: 56, color: schema.outline),
        const SizedBox(height: 16),
        Text(titel, textAlign: TextAlign.center, style: tekst.titleMedium),
        const SizedBox(height: 8),
        Text(uitleg, textAlign: TextAlign.center, style: tekst.bodyMedium),
      ],
    );
  }
}

/// De gesorteerde lijst van een rooster, met een kopregel per deel.
class RoosterLijst extends StatelessWidget {
  const RoosterLijst({
    super.key,
    required this.verdeling,
    required this.onOpenEvent,
    this.toonTeamNamen,
  });

  final RoosterVerdeling verdeling;
  final void Function(Event event) onOpenEvent;

  /// Of de teamnamen bij [item] getoond moeten worden. In het teamrooster is
  /// dat alleen bij een match zinvol: de teamnaam staat al in de kop. In het
  /// persoonlijk rooster hoort hij bij elk item (FR-14).
  final bool Function(RoosterItem item)? toonTeamNamen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      children: [
        if (verdeling.toekomst.isNotEmpty) ...[
          const _Kopregel(tekst: 'Komt eraan', icoon: Icons.upcoming_outlined),
          for (final item in verdeling.toekomst)
            _Regel(
              item: item,
              gedempt: false,
              toonTeamNamen: toonTeamNamen?.call(item) ?? false,
              onTap: item.event == null ? null : () => onOpenEvent(item.event!),
            ),
        ],
        if (verdeling.verleden.isNotEmpty) ...[
          const _Kopregel(tekst: 'Geweest', icoon: Icons.history),
          for (final item in verdeling.verleden)
            _Regel(
              item: item,
              gedempt: true,
              toonTeamNamen: toonTeamNamen?.call(item) ?? false,
              onTap: item.event == null ? null : () => onOpenEvent(item.event!),
            ),
        ],
      ],
    );
  }
}

class _Kopregel extends StatelessWidget {
  const _Kopregel({required this.tekst, required this.icoon});

  final String tekst;
  final IconData icoon;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    final stijl = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(color: schema.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Icon(icoon, size: 18, color: schema.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(tekst, style: stijl),
        ],
      ),
    );
  }
}

class _Regel extends StatelessWidget {
  const _Regel({
    required this.item,
    required this.gedempt,
    required this.toonTeamNamen,
    required this.onTap,
  });

  final RoosterItem item;
  final bool gedempt;
  final bool toonTeamNamen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    final tekstKleur = gedempt ? schema.onSurfaceVariant : null;
    final namen = item.teamNamen.join(', ');
    final bijschrift = [
      periodeTekst(item.start, item.eind),
      if (toonTeamNamen && namen.isNotEmpty) namen,
    ].join('\n');

    return Card(
      child: ListTile(
        leading: Icon(
          item.soort == RoosterSoort.match
              ? Icons.groups_outlined
              : Icons.event_outlined,
          color: gedempt ? schema.outline : schema.primary,
        ),
        title: Text(item.titel, style: TextStyle(color: tekstKleur)),
        subtitle: Text(
          bijschrift,
          style: TextStyle(color: tekstKleur ?? schema.onSurfaceVariant),
        ),
        trailing: item.statusLabel == null
            ? (onTap == null ? null : const Icon(Icons.chevron_right))
            : Chip(
                label: Text(item.statusLabel!),
                visualDensity: VisualDensity.compact,
              ),
        onTap: onTap,
      ),
    );
  }
}
