import 'dart:convert';

import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/api/api_client.dart';
import 'package:crossplatformdevelopment/data/api/token_store.dart';
import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/match_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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
    List<Map<String, dynamic>>? invites,
  }) => {
    'id': id,
    'title': title,
    'description': 'Aangemaakt door het verkenningsscript',
    'datetimeStart': '2026-08-14T13:01:58.000Z',
    'datetimeEnd': '2026-08-14T15:01:58.000Z',
    'location': {'latitude': 52.5168, 'longitude': 5.4714},
    'metadata': {'locatieNaam': 'Windesheim Almere'},
    'teamId': teamId,
    'invites':
        invites ??
        [
          {
            'teamId': 305,
            'status': 'pending',
            'team': {'id': 305, 'name': 'Testteam B'},
          },
        ],
  };

  group('maakMatch', () {
    test('verstuurt titel, tijden in UTC en uitnodigingen', () async {
      Map<String, dynamic>? verzonden;
      String? methode;
      final repo = maakRepository(
        MockClient((verzoek) async {
          methode = verzoek.method;
          verzonden = jsonDecode(verzoek.body) as Map<String, dynamic>;
          return http.Response(succes(matchJson()), 201);
        }),
      );

      final match = await repo.maakMatch(
        teamId: 306,
        titel: 'Testmatch',
        beschrijving: 'Aangemaakt door het verkenningsscript',
        start: DateTime.utc(2026, 8, 14, 13, 1, 58).toLocal(),
        eind: DateTime.utc(2026, 8, 14, 15, 1, 58).toLocal(),
        locatie: const GeoLocatie(latitude: 52.5168, longitude: 5.4714),
        locatieNaam: 'Windesheim Almere',
        uitgenodigdeTeamIds: const [305],
      );

      expect(methode, 'POST');
      expect(verzonden?['title'], 'Testmatch');
      expect(verzonden?['teamId'], 306);
      expect(verzonden?['datetimeStart'], '2026-08-14T13:01:58.000Z');
      expect(verzonden?['invites'], [
        {'teamId': 305},
      ]);
      expect(match.id, 33);
      expect(match.invites.single.status, InviteStatus.pending);
    });

    test(
      'geeft een GeenRechtenException als een lid geen match mag maken',
      () async {
        final repo = maakRepository(
          MockClient((_) async => http.Response(fout(['Forbidden']), 403)),
        );

        await expectLater(
          repo.maakMatch(
            teamId: 306,
            titel: 'Testmatch',
            start: DateTime.utc(2026, 8, 14, 13),
            eind: DateTime.utc(2026, 8, 14, 15),
            uitgenodigdeTeamIds: const [305],
          ),
          throwsA(isA<GeenRechtenException>()),
        );
      },
    );
  });

  group('beantwoordUitnodiging', () {
    test('accepteert een uitnodiging', () async {
      String? methode;
      Uri? pad;
      Map<String, dynamic>? verzonden;
      final repo = maakRepository(
        MockClient((verzoek) async {
          methode = verzoek.method;
          pad = verzoek.url;
          verzonden = jsonDecode(verzoek.body) as Map<String, dynamic>;
          return http.Response(
            succes({'id': 32, 'matchId': 33, 'status': 'accepted'}),
            200,
          );
        }),
      );

      final invite = await repo.beantwoordUitnodiging(
        32,
        InviteStatus.accepted,
      );

      expect(methode, 'POST');
      expect(pad?.path, endsWith('/matches/invites/32'));
      expect(verzonden?['status'], 'accepted');
      expect(invite.status, InviteStatus.accepted);
      expect(invite.id, 32);
    });

    test('wijst een uitnodiging af', () async {
      Map<String, dynamic>? verzonden;
      final repo = maakRepository(
        MockClient((verzoek) async {
          verzonden = jsonDecode(verzoek.body) as Map<String, dynamic>;
          return http.Response(
            succes({'id': 32, 'matchId': 33, 'status': 'declined'}),
            200,
          );
        }),
      );

      final invite = await repo.beantwoordUitnodiging(
        32,
        InviteStatus.declined,
      );

      expect(verzonden?['status'], 'declined');
      expect(invite.status, InviteStatus.declined);
    });
  });
}
