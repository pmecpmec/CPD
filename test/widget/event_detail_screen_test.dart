import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/features/events/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests voor het eventdetail (FR-12) en de routeknop (FR-17).
///
/// Het scherm krijgt het event via de constructor, dus er is geen repository of
/// provider nodig. De route wordt door een testdubbel afgevangen; er gaat geen
/// kaart open.
void main() {
  /// Een event zoals `GET /events` het teruggeeft: met het team erbij en met
  /// tijden die het model al naar lokale tijd heeft omgezet.
  Event maakEvent({
    GeoLocatie? locatie = const GeoLocatie(
      latitude: 52.5168,
      longitude: 5.4714,
    ),
    String? locatieNaam = 'Windesheim Almere',
    String beschrijving = 'Aangemaakt door het verkenningsscript',
  }) => Event(
    id: 88,
    title: 'Testafspraak',
    description: beschrijving,
    start: DateTime(2026, 8, 13, 15, 1),
    end: DateTime(2026, 8, 13, 17, 1),
    teamId: 306,
    location: locatie,
    metadata: locatieNaam == null ? const {} : {'locatieNaam': locatieNaam},
    team: const Team(id: 306, name: 'Testteam A', ownerId: 92),
  );

  Widget bouwScherm(Event event, {RouteStarterDubbel? route}) => MaterialApp(
    home: EventDetailScreen(
      event: event,
      routeStarter: (route ?? RouteStarterDubbel()).start,
    ),
  );

  testWidgets('toont titel, team, tijd, locatie en omschrijving', (
    tester,
  ) async {
    await tester.pumpWidget(bouwScherm(maakEvent()));

    expect(find.text('Testafspraak'), findsOneWidget);
    expect(find.text('Testteam A'), findsOneWidget);
    expect(find.text('13 augustus 2026, 15:01 – 17:01'), findsOneWidget);
    expect(find.textContaining('Windesheim Almere'), findsOneWidget);
    expect(find.textContaining('52.5168, 5.4714'), findsOneWidget);
    expect(find.text('Aangemaakt door het verkenningsscript'), findsOneWidget);
  });

  testWidgets('zet de datum er twee keer bij als het event over een dag heen '
      'loopt', (tester) async {
    final event = Event(
      id: 89,
      title: 'Toernooiweekend',
      start: DateTime(2026, 8, 15, 20, 0),
      end: DateTime(2026, 8, 16, 2, 30),
      teamId: 306,
    );

    await tester.pumpWidget(bouwScherm(event));

    expect(
      find.text('15 augustus 2026, 20:00 – 16 augustus 2026, 02:30'),
      findsOneWidget,
    );
  });

  testWidgets('start de route met de coördinaten van het event', (
    tester,
  ) async {
    final route = RouteStarterDubbel();
    await tester.pumpWidget(bouwScherm(maakEvent(), route: route));

    await tester.tap(find.widgetWithText(FilledButton, 'Route'));
    await tester.pumpAndSettle();

    expect(route.gebruikteLocatie?.latitude, 52.5168);
    expect(route.gebruikteLocatie?.longitude, 5.4714);
    // De plaatsnaam uit metadata komt mee als label bij de pin op de kaart.
    expect(route.gebruikteLabel, 'Windesheim Almere');
  });

  testWidgets('gebruikt de titel als label wanneer er geen plaatsnaam is', (
    tester,
  ) async {
    final route = RouteStarterDubbel();
    await tester.pumpWidget(
      bouwScherm(maakEvent(locatieNaam: null), route: route),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Route'));
    await tester.pumpAndSettle();

    expect(route.gebruikteLabel, 'Testafspraak');
  });

  testWidgets('schakelt de routeknop uit met uitleg als de locatie ontbreekt', (
    tester,
  ) async {
    final route = RouteStarterDubbel();
    await tester.pumpWidget(bouwScherm(maakEvent(locatie: null), route: route));

    final knop = find.widgetWithText(FilledButton, 'Route');
    // Uitgeschakeld, niet onzichtbaar: de gebruiker moet zien dat het bestaat.
    expect(knop, findsOneWidget);
    expect(tester.widget<FilledButton>(knop).onPressed, isNull);
    expect(find.textContaining('geen locatie'), findsWidgets);

    await tester.tap(knop);
    await tester.pumpAndSettle();

    expect(route.aantalPogingen, 0);
  });

  testWidgets('meldt het wanneer er geen kaart-app reageert', (tester) async {
    final route = RouteStarterDubbel(lukt: false);
    await tester.pumpWidget(bouwScherm(maakEvent(), route: route));

    await tester.tap(find.widgetWithText(FilledButton, 'Route'));
    await tester.pumpAndSettle();

    expect(
      find.text('Er is geen kaart-app gevonden om de route te openen.'),
      findsOneWidget,
    );
  });
}

/// Vervangt het echt openen van een kaart-app en onthoudt waarmee het scherm de
/// route wilde starten.
class RouteStarterDubbel {
  RouteStarterDubbel({this.lukt = true});

  final bool lukt;
  GeoLocatie? gebruikteLocatie;
  String? gebruikteLabel;
  int aantalPogingen = 0;

  Future<bool> start(GeoLocatie locatie, {String? label}) async {
    aantalPogingen++;
    gebruikteLocatie = locatie;
    gebruikteLabel = label;
    return lukt;
  }
}
