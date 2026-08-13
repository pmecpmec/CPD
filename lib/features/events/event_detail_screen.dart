import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';
import 'route_starter.dart';

/// FR-12 — de details van één event, met een route naar de locatie (FR-17).
///
/// Het scherm krijgt het event via de constructor mee en haalt zelf niets op.
/// Dat kan omdat `GET /events` het volledige event teruggeeft, inclusief het
/// team; een tweede aanroep om de teamnaam op te zoeken is dus niet nodig. Er
/// is daarom ook geen controller: er valt geen laadstatus of fout te beheren.
class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
    this.routeStarter = startRoute,
  });

  final Event event;

  /// Start de route. Injecteerbaar zodat een test kan controleren dat de knop
  /// werkt, zonder dat er een kaart opengaat. Het scherm kent alleen deze
  /// functie en niet de platformkeuze erachter.
  final RouteStarter routeStarter;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Future<void> _startRoute() async {
    final locatie = widget.event.location;
    if (locatie == null) return;

    final gelukt = await widget.routeStarter(
      locatie,
      // Zonder plaatsnaam is de titel van het event het duidelijkste dat er
      // bij de pin op de kaart kan staan.
      label: widget.event.locatieNaam ?? widget.event.title,
    );
    if (!mounted || gelukt) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(geenKaartAppMelding)));
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final tekst = Theme.of(context).textTheme;
    final locatie = event.location;

    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: InhoudBegrenzer(
        maxBreedte: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(event.title, style: tekst.headlineSmall),
            const SizedBox(height: 20),
            _Gegeven(
              icoon: Icons.group_outlined,
              label: 'Team',
              // Het team komt bij een event altijd mee; valt het toch weg,
              // dan is het id nog altijd informatiever dan een leeg vak.
              waarde: event.team?.name ?? 'Team ${event.teamId}',
            ),
            _Gegeven(
              icoon: Icons.schedule_outlined,
              label: 'Wanneer',
              waarde: _periode(event.start, event.end),
            ),
            _Gegeven(
              icoon: Icons.place_outlined,
              label: 'Locatie',
              waarde: _locatieTekst(event),
            ),
            const Divider(height: 32),
            Text('Omschrijving', style: tekst.titleMedium),
            const SizedBox(height: 4),
            Text(
              event.description.isEmpty
                  ? 'Er is geen omschrijving opgegeven.'
                  : event.description,
              style: tekst.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: locatie == null ? null : _startRoute,
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Route'),
            ),
            if (locatie == null) ...[
              const SizedBox(height: 8),
              Text(
                'Bij dit event staat geen locatie, dus er is geen route te '
                'plannen. Vraag de beheerder om de coördinaten toe te voegen.',
                textAlign: TextAlign.center,
                style: tekst.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Eén regel met een icoon, een label en de waarde eronder.
class _Gegeven extends StatelessWidget {
  const _Gegeven({
    required this.icoon,
    required this.label,
    required this.waarde,
  });

  final IconData icoon;
  final String label;
  final String waarde;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    final tekst = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icoon, size: 20, color: schema.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tekst.labelMedium?.copyWith(color: schema.outline),
                ),
                Text(waarde, style: tekst.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// De locatie in leesbare vorm: de plaatsnaam uit metadata wanneer die er is,
/// met daaronder de coördinaten die de API werkelijk bewaart.
String _locatieTekst(Event event) {
  final locatie = event.location;
  if (locatie == null) return 'Geen locatie vastgelegd';

  final coordinaten = '${locatie.latitude}, ${locatie.longitude}';
  final naam = event.locatieNaam;
  return naam == null || naam.isEmpty ? coordinaten : '$naam\n$coordinaten';
}

/// Begin- en eindtijd in één regel. Valt het event binnen één dag, dan staat de
/// datum er één keer: `13 augustus 2026, 15:01 – 17:01`.
///
/// De tijden zijn al lokaal — de API levert UTC en `Event.fromJson` rekent dat
/// om — dus hier wordt niets meer omgezet. De app heeft geen `intl`-pakket, dus
/// de Nederlandse maandnamen staan hieronder.
String _periode(DateTime start, DateTime eind) {
  final zelfdeDag =
      start.year == eind.year &&
      start.month == eind.month &&
      start.day == eind.day;
  final begin = '${_datum(start)}, ${_tijd(start)}';
  return zelfdeDag
      ? '$begin – ${_tijd(eind)}'
      : '$begin – ${_datum(eind)}, ${_tijd(eind)}';
}

String _datum(DateTime moment) =>
    '${moment.day} ${_maanden[moment.month - 1]} ${moment.year}';

String _tijd(DateTime moment) =>
    '${moment.hour.toString().padLeft(2, '0')}:'
    '${moment.minute.toString().padLeft(2, '0')}';

const List<String> _maanden = [
  'januari',
  'februari',
  'maart',
  'april',
  'mei',
  'juni',
  'juli',
  'augustus',
  'september',
  'oktober',
  'november',
  'december',
];
