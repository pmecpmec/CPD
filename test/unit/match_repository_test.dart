import 'dart:convert';

import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/api/api_client.dart';
import 'package:crossplatformdevelopment/data/api/token_store.dart';
import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/match_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Tests voor de leeskant van de matchlaag (basis voor FR-13 en FR-14).
/// Aanmaken en beantwoorden horen bij T-10 en staan hier expres niet in.
void main() {
  String succes(Object? data) =>
      jsonEncode({'message': 'Success', 'data': data, 'error': null});

  String fout(List<String> meldingen) =>
      jsonEncode({'message': 'Error', 'data': null, 'error': meldingen});

  ApiMatchRepository maakRepository(MockClient httpClient) =>
      ApiMatchRepository(
        ApiClient(httpClient: httpClient, tokenStore: GeheugenTokenStore()),
      );

  Map<String, dynamic> matchJson({
    int id = 33,
    String title = 'Testmatch',
    int teamId = 306,
    String status = 'pending',
  }) => {
    'id': id,
    'title': title,
    'description': 'Aangemaakt door het verkenningsscript',
    'datetimeStart': '2026-08-14T13:01:58.000Z',
    'datetimeEnd': '2026-08-14T15:01:58.000Z',
    'location': {'latitude': 52.5168, 'longitude': 5.4714},
    'teamId': teamId,
    'team': {'id': teamId, 'name': 'Testteam A', 'ownerId': 92},
    'invites': [
      {
        'teamId': 305,
        'status': status,
        'team': {'id': 305, 'name': 'Testteam B', 'ownerId': 93},
      },
    ],
  };

  group('haalMatches', () {
    test('haalt de lijst op, inclusief matches van andere teams', () async {
      Uri? aangeroepen;
      final repo = maakRepository(
        MockClient((verzoek) async {
          aangeroepen = verzoek.url;
          return http.Response(
            succes([
              matchJson(id: 33, teamId: 306),
              matchJson(id: 1, title: 'Friendly Match', teamId: 109),
            ]),
            200,
          );
        }),
      );

      final matches = await repo.haalMatches();

      expect(aangeroepen?.path, endsWith('/matches'));
      expect(matches, hasLength(2));
      expect(matches.first.title, 'Testmatch');
      // GET /matches is niet afgeschermd; filteren op team is werk voor de
      // controller (FR-13, FR-14).
      expect(matches.map((m) => m.teamId), [306, 109]);
      expect(matches.first.invites.single.status, InviteStatus.pending);
    });

    test('geeft een lege lijst terug wanneer er niets is', () async {
      final repo = maakRepository(
        MockClient((_) async => http.Response(succes(const []), 200)),
      );

      expect(await repo.haalMatches(), isEmpty);
    });

    test('geeft een lege lijst terug bij een onverwacht antwoord', () async {
      final repo = maakRepository(
        MockClient((_) async => http.Response(succes(null), 200)),
      );

      expect(await repo.haalMatches(), isEmpty);
    });
  });

  group('haalMatch', () {
    test('leest één match op id', () async {
      Uri? aangeroepen;
      final repo = maakRepository(
        MockClient((verzoek) async {
          aangeroepen = verzoek.url;
          return http.Response(
            succes(matchJson(id: 33, status: 'accepted')),
            200,
          );
        }),
      );

      final match = await repo.haalMatch(33);

      expect(aangeroepen?.path, endsWith('/matches/33'));
      expect(match.id, 33);
      expect(match.alleGeaccepteerd, isTrue);
      expect(match.start.isUtc, isFalse, reason: 'lokaal tonen, UTC versturen');
    });

    test('meldt het wanneer de match niet bestaat', () async {
      final repo = maakRepository(
        MockClient((_) async => http.Response(fout(['Not found']), 404)),
      );

      await expectLater(
        repo.haalMatch(99),
        throwsA(isA<NietGevondenException>()),
      );
    });
  });
}
