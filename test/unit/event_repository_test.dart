import 'dart:convert';

import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/api/api_client.dart';
import 'package:crossplatformdevelopment/data/api/token_store.dart';
import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/event_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Tests voor de eventlaag (basis voor FR-11 tot en met FR-14). Er wordt geen
/// echte server benaderd: de HTTP-laag is vervangen door een testdubbel, zodat
/// de tests snel zijn en altijd hetzelfde resultaat geven (NFR-06).
///
/// De antwoorden hieronder volgen de envelop die de API gebruikt:
///   succes  {"message": "Success", "data": {...}, "error": null}
///   fout    {"message": "Error", "data": null, "errors": ["..."]}
void main() {
  String succes(Object? data) =>
      jsonEncode({'message': 'Success', 'data': data, 'error': null});

  String fout(List<String> meldingen) =>
      jsonEncode({'message': 'Error', 'data': null, 'errors': meldingen});

  ApiEventRepository maakRepository(MockClient httpClient) =>
      ApiEventRepository(
        ApiClient(httpClient: httpClient, tokenStore: GeheugenTokenStore()),
      );

  /// Een antwoord zoals `GET /events` het volgens de documentatie teruggeeft.
  Map<String, dynamic> eventJson({
    int id = 1,
    String title = 'Team Meeting',
    int teamId = 3,
    Map<String, dynamic>? location = const {
      'latitude': 37.7749,
      'longitude': -122.4194,
    },
  }) => {
    'id': id,
    'title': title,
    'description': 'Maandelijkse teamvergadering',
    'datetimeStart': '2024-09-01T10:00:00.000Z',
    'datetimeEnd': '2024-09-01T12:00:00.000Z',
    'location': location,
    'teamId': teamId,
    'metadata': {'locatieNaam': 'Kantoor Almere'},
  };

  group('haalEvents', () {
    test('haalt de events van alle teams van de gebruiker op', () async {
      Uri? aangeroepen;
      final repo = maakRepository(
        MockClient((verzoek) async {
          aangeroepen = verzoek.url;
          return http.Response(
            succes([
              eventJson(id: 1, title: 'Training', teamId: 3),
              eventJson(id: 2, title: 'Toernooi', teamId: 8),
            ]),
            200,
          );
        }),
      );

      final events = await repo.haalEvents();

      expect(aangeroepen?.path, endsWith('/events'));
      expect(events, hasLength(2));
      expect(events.first.title, 'Training');
      // Twee verschillende teams: het scheiden van team- en persoonlijk
      // rooster gebeurt in de app, niet in de API (FR-13, FR-14).
      expect(events.map((e) => e.teamId), [3, 8]);
      expect(events.first.location?.latitude, 37.7749);
      expect(events.first.locatieNaam, 'Kantoor Almere');
    });

    test('geeft een lege lijst terug wanneer er niets gepland is', () async {
      final repo = maakRepository(
        MockClient((_) async => http.Response(succes(const []), 200)),
      );

      expect(await repo.haalEvents(), isEmpty);
    });

    test('geeft een lege lijst terug bij een onverwacht antwoord', () async {
      final repo = maakRepository(
        MockClient((_) async => http.Response(succes(null), 200)),
      );

      expect(await repo.haalEvents(), isEmpty);
    });
  });

  group('haalEvent', () {
    test('leest één event op id', () async {
      Uri? aangeroepen;
      final repo = maakRepository(
        MockClient((verzoek) async {
          aangeroepen = verzoek.url;
          return http.Response(succes(eventJson(id: 42)), 200);
        }),
      );

      final event = await repo.haalEvent(42);

      expect(aangeroepen?.path, endsWith('/events/42'));
      expect(event.id, 42);
      expect(event.start.isUtc, isFalse, reason: 'lokaal tonen, UTC versturen');
    });

    test('meldt het wanneer het event niet bestaat', () async {
      final repo = maakRepository(
        MockClient((_) async => http.Response(fout(['Not found']), 404)),
      );

      await expectLater(
        repo.haalEvent(99),
        throwsA(isA<NietGevondenException>()),
      );
    });
  });

  group('maakEvent', () {
    test('verstuurt titel, tijden in UTC en een coördinatenpaar', () async {
      Map<String, dynamic>? verzonden;
      String? methode;
      final repo = maakRepository(
        MockClient((verzoek) async {
          methode = verzoek.method;
          verzonden = jsonDecode(verzoek.body) as Map<String, dynamic>;
          return http.Response(
            succes(eventJson(id: 5, title: 'Training')),
            201,
          );
        }),
      );

      final event = await repo.maakEvent(
        teamId: 3,
        titel: 'Training',
        beschrijving: 'Wekelijkse training',
        // Bewust lokale tijden, zodat de omzetting naar UTC aantoonbaar is en
        // de test niet afhangt van de tijdzone van de machine.
        start: DateTime.utc(2026, 9, 1, 10).toLocal(),
        eind: DateTime.utc(2026, 9, 1, 12).toLocal(),
        locatie: const GeoLocatie(latitude: 52.5, longitude: 5.47),
        locatieNaam: 'Sporthal Almere',
      );

      expect(methode, 'POST');
      expect(verzonden?['title'], 'Training');
      expect(verzonden?['description'], 'Wekelijkse training');
      expect(verzonden?['teamId'], 3);
      expect(verzonden?['datetimeStart'], '2026-09-01T10:00:00.000Z');
      expect(verzonden?['datetimeEnd'], '2026-09-01T12:00:00.000Z');
      expect(verzonden?['location'], {'latitude': 52.5, 'longitude': 5.47});
      expect(verzonden?['metadata'], {'locatieNaam': 'Sporthal Almere'});
      expect(event.id, 5);
    });

    test('laat de locatie weg wanneer die niet is opgegeven', () async {
      Map<String, dynamic>? verzonden;
      final repo = maakRepository(
        MockClient((verzoek) async {
          verzonden = jsonDecode(verzoek.body) as Map<String, dynamic>;
          return http.Response(succes(eventJson(location: null)), 201);
        }),
      );

      final event = await repo.maakEvent(
        teamId: 3,
        titel: 'Overleg',
        start: DateTime.utc(2026, 9, 1, 10),
        eind: DateTime.utc(2026, 9, 1, 11),
      );

      expect(verzonden?.containsKey('location'), isFalse);
      expect(verzonden?['metadata'], isEmpty);
      // Zonder locatie is de routeknop niet beschikbaar (FR-17).
      expect(event.location, isNull);
    });

    test(
      'geeft een GeenRechtenException als een lid geen event mag maken',
      () async {
        final repo = maakRepository(
          MockClient((_) async => http.Response(fout(['Forbidden']), 403)),
        );

        await expectLater(
          repo.maakEvent(
            teamId: 3,
            titel: 'Training',
            start: DateTime.utc(2026, 9, 1, 10),
            eind: DateTime.utc(2026, 9, 1, 12),
          ),
          throwsA(
            isA<GeenRechtenException>().having(
              (e) => e.bericht,
              'bericht',
              'Forbidden',
            ),
          ),
        );
      },
    );
  });

  group('wijzigEvent en verwijderEvent', () {
    test('stuurt een PUT naar het event zonder teamId mee te sturen', () async {
      Map<String, dynamic>? verzonden;
      String? methode;
      Uri? aangeroepen;
      final repo = maakRepository(
        MockClient((verzoek) async {
          methode = verzoek.method;
          aangeroepen = verzoek.url;
          verzonden = jsonDecode(verzoek.body) as Map<String, dynamic>;
          return http.Response(
            succes(eventJson(id: 7, title: 'Nieuwe titel')),
            200,
          );
        }),
      );

      final event = await repo.wijzigEvent(
        7,
        titel: 'Nieuwe titel',
        start: DateTime.utc(2026, 9, 1, 10),
        eind: DateTime.utc(2026, 9, 1, 12),
      );

      expect(methode, 'PUT');
      expect(aangeroepen?.path, endsWith('/events/7'));
      expect(verzonden?.containsKey('teamId'), isFalse);
      expect(event.title, 'Nieuwe titel');
    });

    test('stuurt een DELETE naar het event', () async {
      String? methode;
      Uri? aangeroepen;
      final repo = maakRepository(
        MockClient((verzoek) async {
          methode = verzoek.method;
          aangeroepen = verzoek.url;
          return http.Response(succes(null), 200);
        }),
      );

      await repo.verwijderEvent(7);

      expect(methode, 'DELETE');
      expect(aangeroepen?.path, endsWith('/events/7'));
    });
  });
}
