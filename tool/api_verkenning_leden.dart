// Verkenningsscript voor de ledenacties van de Team Management API.
//
// T-01 heeft `POST /teams/{id}/removeUser`, `POST /teams/{id}/leave` en
// `DELETE /teams/{id}` niet aangeroepen, en heeft ook niet gemeten wat de API
// doet bij een verboden actie. Dat zijn precies de aanroepen die het
// teamdetailscherm nodig heeft (taak T-03, FR-07 en FR-08).
//
// Dit script vult dat gat: twee gebruikers, één team, en dan elke ledenactie
// zowel als beheerder als als gewoon lid. De uitvoer hoort in
// `docs/api-waargenomen-gedrag.md`.
//
// Draaien:
//   dart run tool/api_verkenning_leden.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

const basisUrl = 'https://team-managment-api.dendrowen.com/api/v2';

final _client = http.Client();

Future<void> main() async {
  final suffix = Random().nextInt(999999).toString().padLeft(6, '0');
  final naamA = 'ledentest${suffix}a';
  final naamB = 'ledentest${suffix}b';
  const wachtwoord = 'TestWachtwoord123';

  stdout.writeln('Gebruiker A (beheerder): $naamA');
  stdout.writeln('Gebruiker B (gewoon lid): $naamB');

  try {
    await _stap(
      '1. Registreren A',
      'POST',
      '/auth/register',
      body: {'name': naamA, 'password': wachtwoord},
    );
    final loginA = await _stap(
      '2. Inloggen A',
      'POST',
      '/auth/login',
      body: {'name': naamA, 'password': wachtwoord},
    );
    final tokenA = _veld(loginA, 'token') as String?;
    final userIdA = _veld(loginA, 'id') as int?;

    await _stap(
      '3. Registreren B',
      'POST',
      '/auth/register',
      body: {'name': naamB, 'password': wachtwoord},
    );
    final loginB = await _stap(
      '4. Inloggen B',
      'POST',
      '/auth/login',
      body: {'name': naamB, 'password': wachtwoord},
    );
    final tokenB = _veld(loginB, 'token') as String?;
    final userIdB = _veld(loginB, 'id') as int?;

    stdout.writeln('\n>> userId A: $userIdA, userId B: $userIdB');

    final team = await _stap(
      '5. Team aanmaken als A',
      'POST',
      '/teams',
      token: tokenA,
      body: {
        'name': 'Ledentest $suffix',
        'description': 'Team voor het meten van removeUser en leave',
        'metadata': {'Icon': 'group'},
      },
    );
    final teamId = _veld(team, 'id') as int?;
    stdout.writeln('>> teamId: $teamId');
    if (teamId == null) return;

    await _stap(
      '6. B toevoegen aan het team (als A)',
      'POST',
      '/teams/$teamId/addUser',
      token: tokenA,
      body: {'userId': userIdB},
    );

    // --- verboden acties: B is gewoon lid ---------------------------------
    await _stap(
      '7. B probeert A te verwijderen (verboden actie)',
      'POST',
      '/teams/$teamId/removeUser',
      token: tokenB,
      body: {'userId': userIdA},
    );

    await _stap(
      '8. B probeert het team te verwijderen (verboden actie)',
      'DELETE',
      '/teams/$teamId',
      token: tokenB,
    );

    await _stap(
      '9. B probeert het team te wijzigen (verboden actie)',
      'PUT',
      '/teams/$teamId',
      token: tokenB,
      body: {'name': 'Gekaapt', 'description': 'Door een gewoon lid'},
    );

    // --- B vertrekt zelf ---------------------------------------------------
    await _stap(
      '10. B verlaat het team',
      'POST',
      '/teams/$teamId/leave',
      token: tokenB,
      body: const {},
    );

    await _stap(
      '11. Team ophalen als A na het vertrek van B',
      'GET',
      '/teams/$teamId',
      token: tokenA,
    );

    await _stap(
      '12. B verlaat een team waar hij niet in zit',
      'POST',
      '/teams/$teamId/leave',
      token: tokenB,
      body: const {},
    );

    await _stap(
      '13. Team ophalen als niet-lid B',
      'GET',
      '/teams/$teamId',
      token: tokenB,
    );

    // --- beheerder verwijdert een lid -------------------------------------
    await _stap(
      '14. B opnieuw toevoegen (als A)',
      'POST',
      '/teams/$teamId/addUser',
      token: tokenA,
      body: {'userId': userIdB},
    );

    await _stap(
      '15. B nog een keer toevoegen: dubbel toevoegen',
      'POST',
      '/teams/$teamId/addUser',
      token: tokenA,
      body: {'userId': userIdB},
    );

    await _stap(
      '16. A verwijdert B uit het team',
      'POST',
      '/teams/$teamId/removeUser',
      token: tokenA,
      body: {'userId': userIdB},
    );

    await _stap(
      '17. A verwijdert B nog een keer (niet meer lid)',
      'POST',
      '/teams/$teamId/removeUser',
      token: tokenA,
      body: {'userId': userIdB},
    );

    // --- de beheerder zelf -------------------------------------------------
    await _stap(
      '18. A (de beheerder) probeert zelf te vertrekken',
      'POST',
      '/teams/$teamId/leave',
      token: tokenA,
      body: const {},
    );

    await _stap(
      '19. A verwijdert het team',
      'DELETE',
      '/teams/$teamId',
      token: tokenA,
    );

    await _stap(
      '20. Verwijderd team opvragen',
      'GET',
      '/teams/$teamId',
      token: tokenA,
    );
  } finally {
    _client.close();
  }

  stdout.writeln('\nKlaar.');
}

Future<dynamic> _stap(
  String omschrijving,
  String methode,
  String pad, {
  String? token,
  Object? body,
}) async {
  stdout.writeln('\n${'-' * 70}');
  stdout.writeln('$omschrijving  ($methode $pad)');
  stdout.writeln('-' * 70);
  if (body != null) stdout.writeln('Verzoek: ${jsonEncode(body)}');

  final uri = Uri.parse('$basisUrl$pad');
  final headers = <String, String>{'Accept': 'application/json'};
  if (body != null) headers['Content-Type'] = 'application/json';
  if (token != null) headers['Authorization'] = 'Bearer $token';

  http.Response antwoord;
  try {
    antwoord = switch (methode) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ),
      'PUT' => await _client.put(uri, headers: headers, body: jsonEncode(body)),
      'DELETE' => await _client.delete(uri, headers: headers),
      _ => throw ArgumentError(methode),
    };
  } catch (e) {
    stdout.writeln('FOUT bij de aanroep: $e');
    return null;
  }

  stdout.writeln('Status: ${antwoord.statusCode}');
  if (antwoord.body.isEmpty) {
    stdout.writeln('(leeg antwoord)');
    return null;
  }
  try {
    final data = jsonDecode(antwoord.body);
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(data));
    return data;
  } on FormatException {
    stdout.writeln('(geen JSON)');
    stdout.writeln(antwoord.body);
    return null;
  }
}

/// Leest een veld uit het `data`-object van de envelop.
dynamic _veld(dynamic antwoord, String sleutel) {
  if (antwoord is! Map) return null;
  final data = antwoord['data'];
  if (data is Map) return data[sleutel];
  return antwoord[sleutel];
}
