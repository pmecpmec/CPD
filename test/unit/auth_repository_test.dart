import 'dart:convert';

import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/api/api_client.dart';
import 'package:crossplatformdevelopment/data/api/token_store.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Tests voor de authenticatielaag. Er wordt geen echte server benaderd: de
/// HTTP-laag is vervangen door een testdubbel, zodat de tests snel zijn en
/// altijd hetzelfde resultaat geven (NFR-06).
///
/// De antwoorden hieronder volgen de envelop die de API gebruikt:
///   succes  {"message": "Success", "data": {...}, "error": null}
///   fout    {"message": "Error", "data": null, "errors": ["..."]}
void main() {
  late GeheugenTokenStore tokenStore;

  String succes(Object? data) =>
      jsonEncode({'message': 'Success', 'data': data, 'error': null});

  String fout(List<String> meldingen) =>
      jsonEncode({'message': 'Error', 'data': null, 'errors': meldingen});

  ApiAuthRepository maakRepository(MockClient httpClient) {
    tokenStore = GeheugenTokenStore();
    final client = ApiClient(httpClient: httpClient, tokenStore: tokenStore);
    return ApiAuthRepository(client: client, tokenStore: tokenStore);
  }

  group('login', () {
    test(
      'bewaart het token en het gebruikers-id bij een geslaagde poging',
      () async {
        final repo = maakRepository(
          MockClient((verzoek) async {
            expect(verzoek.url.path, endsWith('/auth/login'));
            expect(jsonDecode(verzoek.body), {
              'name': 'pedro',
              'password': 'geheim',
            });
            return http.Response(
              succes({'id': 7, 'name': 'pedro', 'token': 'abc123'}),
              200,
            );
          }),
        );

        await repo.login(naam: 'pedro', wachtwoord: 'geheim');

        expect(await tokenStore.leesToken(), 'abc123');
        expect(await tokenStore.leesGebruikerId(), 7);
        expect(await repo.heeftSessie(), isTrue);
      },
    );

    test('geeft een duidelijke fout bij verkeerde inloggegevens', () async {
      final repo = maakRepository(
        MockClient(
          (_) async =>
              http.Response(fout(['Invalid username or password']), 401),
        ),
      );

      await expectLater(
        repo.login(naam: 'pedro', wachtwoord: 'fout'),
        throwsA(isA<OngeldigeInlogException>()),
      );
      expect(await repo.heeftSessie(), isFalse);
    });

    test('meldt het wanneer de server geen token teruggeeft', () async {
      final repo = maakRepository(
        MockClient(
          (_) async => http.Response(succes({'id': 1, 'name': 'x'}), 200),
        ),
      );

      await expectLater(
        repo.login(naam: 'pedro', wachtwoord: 'geheim'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('sessie', () {
    test('stuurt het token mee in de Authorization-header', () async {
      String? meegestuurdeHeader;
      final repo = maakRepository(
        MockClient((verzoek) async {
          meegestuurdeHeader = verzoek.headers['Authorization'];
          return http.Response(succes({'id': 1, 'token': 'xyz'}), 200);
        }),
      );

      await repo.login(naam: 'a', wachtwoord: 'b');
      expect(
        meegestuurdeHeader,
        isNull,
        reason: 'bij het inloggen is er nog geen token',
      );

      await repo.login(naam: 'a', wachtwoord: 'b');
      expect(meegestuurdeHeader, 'Bearer xyz');
    });

    test('logout wist de bewaarde sessie', () async {
      final repo = maakRepository(
        MockClient((_) async => http.Response(succes({'token': 't'}), 200)),
      );

      await repo.login(naam: 'a', wachtwoord: 'b');
      expect(await repo.heeftSessie(), isTrue);

      await repo.logout();
      expect(await repo.heeftSessie(), isFalse);
      expect(await repo.huidigeGebruikerId(), isNull);
    });
  });

  group('foutafhandeling', () {
    test('vertaalt een serverfout naar een leesbare melding', () async {
      final repo = maakRepository(
        MockClient((_) async => http.Response('', 500)),
      );

      await expectLater(
        repo.registreer(naam: 'a', wachtwoord: 'b'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.bericht,
            'bericht',
            contains('server'),
          ),
        ),
      );
    });

    test('neemt de melding uit het errors-veld over', () async {
      final repo = maakRepository(
        MockClient(
          (_) async => http.Response(fout(['Username already taken']), 400),
        ),
      );

      await expectLater(
        repo.registreer(naam: 'a', wachtwoord: 'b'),
        throwsA(
          isA<ValidatieException>().having(
            (e) => e.bericht,
            'bericht',
            'Username already taken',
          ),
        ),
      );
    });
  });
}
