import 'dart:convert';

import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/api/api_client.dart';
import 'package:crossplatformdevelopment/data/api/token_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Tests op de envelop en de foutvertaling. Dit is de laag waar alle andere
/// aanroepen doorheen gaan, dus een fout hier raakt de hele app.
void main() {
  ApiClient maakClient(MockClient httpClient, {String? token}) {
    final store = GeheugenTokenStore();
    if (token != null) store.schrijfToken(token);
    return ApiClient(httpClient: httpClient, tokenStore: store);
  }

  test('pakt het data-veld uit de envelop', () async {
    final client = maakClient(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message': 'Success',
            'data': {'id': 3, 'name': 'Testteam'},
            'error': null,
          }),
          200,
        ),
      ),
    );

    final resultaat = await client.get('/teams/3');
    expect(resultaat, {'id': 3, 'name': 'Testteam'});
  });

  test('geeft een lijst uit de envelop als lijst terug', () async {
    final client = maakClient(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message': 'Success',
            'data': [
              {'id': 1},
              {'id': 2},
            ],
            'error': null,
          }),
          200,
        ),
      ),
    );

    final resultaat = await client.get('/teams');
    expect(resultaat, isA<List>().having((l) => l.length, 'lengte', 2));
  });

  test('laat een antwoord zonder envelop ongemoeid', () async {
    final client = maakClient(
      MockClient((_) async => http.Response(jsonEncode({'id': 9}), 200)),
    );

    expect(await client.get('/iets'), {'id': 9});
  });

  test('meldt een verlopen sessie alleen wanneer er een token meeging', () async {
    var gemeld = false;
    final zonderToken = maakClient(
      MockClient((_) async => http.Response('{"message":"Error"}', 401)),
    )..bijSessieVerlopen = () => gemeld = true;

    await expectLater(
      zonderToken.post('/auth/login'),
      throwsA(isA<SessieVerlopenException>()),
    );
    expect(gemeld, isFalse, reason: 'zonder token is er geen sessie verlopen');

    var gemeldMet = false;
    final metToken = maakClient(
      MockClient((_) async => http.Response('{"message":"Error"}', 401)),
      token: 'abc',
    )..bijSessieVerlopen = () => gemeldMet = true;

    await expectLater(
      metToken.get('/teams'),
      throwsA(isA<SessieVerlopenException>()),
    );
    expect(gemeldMet, isTrue);
  });

  test('vertaalt 403 en 404 naar de bijbehorende fouten', () async {
    final verboden = maakClient(
      MockClient((_) async => http.Response('', 403)),
    );
    await expectLater(
      verboden.delete('/teams/1'),
      throwsA(isA<GeenRechtenException>()),
    );

    final onbekend = maakClient(MockClient((_) async => http.Response('', 404)));
    await expectLater(
      onbekend.get('/teams/999'),
      throwsA(isA<NietGevondenException>()),
    );
  });
}
