import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/event_repository.dart';
import 'package:crossplatformdevelopment/features/events/event_form_controller.dart';
import 'package:crossplatformdevelopment/features/events/event_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Widgettests voor het aanmaken van een event (FR-11).
///
/// De nadruk ligt op de controle vóór verzending: elke afgekeurde invoer moet
/// een melding geven én de repository ongemoeid laten. Dat laatste is het
/// bewijs dat er geen verzoek uitgaat dat de server toch zou weigeren.
void main() {
  /// Het moment waarop het formulier "geopend" wordt. Een vaste waarde, zodat
  /// de begintijd niet van de klok van de machine afhangt.
  final nu = DateTime(2026, 8, 20, 9, 30);

  /// Testdubbel voor de eventlaag: geen netwerk, en het onthoudt waarmee het is
  /// aangeroepen (NFR-06).
  late NepEventRepository events;

  setUp(() => events = NepEventRepository());

  EventFormController bouwController() =>
      EventFormController(eventRepository: events, teamId: 306, nu: nu);

  /// Zet het formulier neer op een venster dat hoog genoeg is om het hele
  /// formulier te tonen. Zonder dat bouwt de `ListView` de onderste velden en
  /// de verzendknop niet, en is er niets om op te tikken.
  Future<void> open(WidgetTester tester, EventFormController controller) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: EventFormScreen()),
      ),
    );
  }

  Future<void> vulIn(
    WidgetTester tester, {
    String? titel,
    String? breedtegraad,
    String? lengtegraad,
    String? plaatsnaam,
  }) async {
    if (titel != null) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titel'),
        titel,
      );
    }
    if (breedtegraad != null) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Breedtegraad'),
        breedtegraad,
      );
    }
    if (lengtegraad != null) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Lengtegraad'),
        lengtegraad,
      );
    }
    if (plaatsnaam != null) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Plaatsnaam'),
        plaatsnaam,
      );
    }
  }

  Future<void> verstuur(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Event aanmaken'));
    await tester.pumpAndSettle();
  }

  group('validatie vóór verzending (FR-11)', () {
    testWidgets('een lege titel wordt geweigerd', (tester) async {
      await open(tester, bouwController());
      await verstuur(tester);

      expect(find.text('Vul een titel in.'), findsOneWidget);
      expect(events.aanroepen, isEmpty);
    });

    testWidgets('een eindtijd vóór de begintijd wordt geweigerd', (
      tester,
    ) async {
      final controller = bouwController();
      await open(tester, controller);
      await vulIn(tester, titel: 'Training');

      // Een uur vóór de begintijd, zoals de gebruiker die met de tijdkiezer
      // zou kunnen zetten.
      controller.zetEind(controller.begin.subtract(const Duration(hours: 1)));
      await tester.pumpAndSettle();

      expect(
        find.text('De eindtijd moet ná de begintijd liggen.'),
        findsOneWidget,
      );

      await verstuur(tester);
      expect(events.aanroepen, isEmpty);
    });

    testWidgets('een gelijke begin- en eindtijd wordt ook geweigerd', (
      tester,
    ) async {
      final controller = bouwController();
      await open(tester, controller);
      await vulIn(tester, titel: 'Training');

      controller.zetEind(controller.begin);
      await verstuur(tester);

      expect(
        find.text('De eindtijd moet ná de begintijd liggen.'),
        findsOneWidget,
      );
      expect(events.aanroepen, isEmpty);
    });

    testWidgets('een breedtegraad buiten het bereik wordt geweigerd', (
      tester,
    ) async {
      await open(tester, bouwController());
      await vulIn(
        tester,
        titel: 'Training',
        breedtegraad: '91',
        lengtegraad: '5.4714',
      );
      await verstuur(tester);

      expect(
        find.text('Een breedtegraad ligt tussen -90 en 90.'),
        findsOneWidget,
      );
      expect(events.aanroepen, isEmpty);
    });

    testWidgets('een lengtegraad buiten het bereik wordt geweigerd', (
      tester,
    ) async {
      await open(tester, bouwController());
      await vulIn(
        tester,
        titel: 'Training',
        breedtegraad: '52.5168',
        lengtegraad: '-200',
      );
      await verstuur(tester);

      expect(
        find.text('Een lengtegraad ligt tussen -180 en 180.'),
        findsOneWidget,
      );
      expect(events.aanroepen, isEmpty);
    });

    testWidgets('één helft van een coördinatenpaar wordt geweigerd', (
      tester,
    ) async {
      await open(tester, bouwController());
      await vulIn(tester, titel: 'Training', breedtegraad: '52.5168');
      await verstuur(tester);

      expect(
        find.text('Vul beide coördinaten in, of laat ze beide leeg.'),
        findsWidgets,
      );
      expect(events.aanroepen, isEmpty);
    });
  });

  group('verzenden', () {
    testWidgets('stuurt titel, periode, coördinaten en plaatsnaam mee', (
      tester,
    ) async {
      final controller = bouwController();
      await open(tester, controller);
      await vulIn(
        tester,
        titel: '  Training  ',
        // Een komma als decimaalteken: dat biedt een Nederlands toetsenbord aan.
        breedtegraad: '52,5168',
        lengtegraad: '5.4714',
        plaatsnaam: 'Windesheim Almere',
      );
      await verstuur(tester);

      expect(events.aanroepen, hasLength(1));
      final aanroep = events.aanroepen.single;
      expect(aanroep.teamId, 306);
      expect(aanroep.titel, 'Training', reason: 'witruimte eraf');
      expect(aanroep.start, DateTime(2026, 8, 20, 10));
      expect(aanroep.eind, DateTime(2026, 8, 20, 11));
      expect(aanroep.locatie?.latitude, 52.5168);
      expect(aanroep.locatie?.longitude, 5.4714);
      expect(aanroep.locatieNaam, 'Windesheim Almere');
    });

    testWidgets('een event zonder coördinaten krijgt geen locatie', (
      tester,
    ) async {
      await open(tester, bouwController());
      await vulIn(tester, titel: 'Teamoverleg');
      await verstuur(tester);

      expect(events.aanroepen, hasLength(1));
      // Zonder locatie is er alleen geen route te plannen (FR-17); het event
      // mag wel bestaan.
      expect(events.aanroepen.single.locatie, isNull);
      expect(events.aanroepen.single.locatieNaam, isNull);
    });

    testWidgets('toont de melding uit errors.dart als de server weigert', (
      tester,
    ) async {
      events = NepEventRepository(fout: const GeenRechtenException());
      await open(tester, bouwController());
      await vulIn(tester, titel: 'Training');
      await verstuur(tester);

      expect(
        find.text(const GeenRechtenException().bericht),
        findsOneWidget,
        reason: 'de API weigert een event van een gewoon lid met 403',
      );
    });
  });
}

/// Wat er bij één aanroep van `maakEvent` is meegegeven.
typedef Aanroep = ({
  int teamId,
  String titel,
  DateTime start,
  DateTime eind,
  GeoLocatie? locatie,
  String? locatieNaam,
});

class NepEventRepository implements EventRepository {
  NepEventRepository({this.fout});

  final AppException? fout;
  final List<Aanroep> aanroepen = [];

  @override
  Future<Event> maakEvent({
    required int teamId,
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving = '',
    GeoLocatie? locatie,
    String? locatieNaam,
  }) async {
    if (fout != null) throw fout!;
    aanroepen.add((
      teamId: teamId,
      titel: titel,
      start: start,
      eind: eind,
      locatie: locatie,
      locatieNaam: locatieNaam,
    ));
    return Event(
      id: 88,
      title: titel,
      start: start,
      end: eind,
      teamId: teamId,
      location: locatie,
      metadata: {'locatieNaam': ?locatieNaam},
    );
  }

  @override
  Future<List<Event>> haalEvents() async => const [];

  @override
  Future<Event> haalEvent(int id) => throw UnimplementedError();

  @override
  Future<Event> wijzigEvent(
    int id, {
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving = '',
    GeoLocatie? locatie,
    String? locatieNaam,
    int? teamId,
  }) => throw UnimplementedError();

  @override
  Future<void> verwijderEvent(int id) => throw UnimplementedError();
}
