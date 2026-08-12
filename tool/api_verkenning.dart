// Verkenningsscript voor de Team Management API.
//
// Draait de hele keten door — registreren, inloggen, team aanmaken, ophalen,
// event aanmaken, ophalen — en print bij elke stap de ruwe reactie. Daarmee
// staat zwart op wit hoe de antwoorden eruitzien, wat nodig is om de modellen
// in `lib/data/models/models.dart` te kunnen kloppen.
//
// Draaien:
//   dart run tool/api_verkenning.dart
//
// Er wordt telkens een nieuwe testgebruiker aangemaakt met een willekeurige
// naam, zodat het script meerdere keren gedraaid kan worden zonder botsing.
// De uitvoer is ook bruikbaar als bijlage bij het testplan in het SDD.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

const basisUrl = 'https://team-managment-api.dendrowen.com/api/v2';

String? _token;
final _client = http.Client();

Future<void> main() async {
  final suffix = Random().nextInt(999999).toString().padLeft(6, '0');
  final naam = 'testuser$suffix';
  const wachtwoord = 'TestWachtwoord123';

  stdout.writeln('Testgebruiker: $naam');
  stdout.writeln('Basis-URL:     $basisUrl');

  try {
    await _stap(
      '1. Registreren',
      'POST',
      '/auth/register',
      body: {'name': naam, 'password': wachtwoord},
    );

    final login = await _stap(
      '2. Inloggen',
      'POST',
      '/auth/login',
      body: {'name': naam, 'password': wachtwoord},
    );
    _token = _zoekToken(login);
    stdout.writeln(
      _token == null
          ? '   >> LET OP: geen token gevonden in het antwoord hierboven.'
          : '   >> Token gevonden, lengte ${_token!.length}.',
    );

    final team = await _stap(
      '3. Team aanmaken',
      'POST',
      '/teams',
      body: {
        'name': 'Testteam $suffix',
        'description': 'Aangemaakt door het verkenningsscript',
        'metadata': {'Icon': 'calendar_today'},
      },
    );
    final teamId = _zoekId(team);
    stdout.writeln('   >> teamId: ${teamId ?? "niet gevonden"}');

    await _stap('4. Teams ophalen', 'GET', '/teams');

    if (teamId != null) {
      await _stap('5. Eén team ophalen', 'GET', '/teams/$teamId');

      final nu = DateTime.now().toUtc();
      await _stap(
        '6. Event aanmaken',
        'POST',
        '/events',
        body: {
          'title': 'Testafspraak',
          'description': 'Aangemaakt door het verkenningsscript',
          'datetimeStart': nu.add(const Duration(days: 1)).toIso8601String(),
          'datetimeEnd': nu
              .add(const Duration(days: 1, hours: 2))
              .toIso8601String(),
          'location': {'latitude': 52.5168, 'longitude': 5.4714},
          'teamId': teamId,
          'metadata': {'locatieNaam': 'Windesheim Almere'},
        },
      );

      await _stap('7. Events ophalen', 'GET', '/events');
    }

    await _stap('8. Matches ophalen', 'GET', '/matches');
    await _stap('9. Uitnodigingen ophalen', 'GET', '/matches/invites');
    await _stap('10. Verlopen token', 'GET', '/dev/expired-token');
  } finally {
    _client.close();
  }

  stdout.writeln('\nKlaar. Kopieer de uitvoer hierboven naar de chat.');
}

/// Voert één aanroep uit en print methode, pad, statuscode en het volledige
/// antwoord, netjes ingesprongen zodat de structuur af te lezen is.
Future<dynamic> _stap(
  String omschrijving,
  String methode,
  String pad, {
  Object? body,
}) async {
  stdout.writeln('\n${'-' * 70}');
  stdout.writeln('$omschrijving  ($methode $pad)');
  stdout.writeln('-' * 70);

  final uri = Uri.parse('$basisUrl$pad');
  final headers = <String, String>{'Accept': 'application/json'};
  if (body != null) headers['Content-Type'] = 'application/json';
  if (_token != null) headers['Authorization'] = 'Bearer $_token';

  http.Response antwoord;
  try {
    antwoord = switch (methode) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ),
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

String? _zoekToken(dynamic data) {
  if (data is! Map) return null;
  for (final sleutel in ['token', 'accessToken', 'access_token', 'jwt']) {
    final waarde = data[sleutel];
    if (waarde is String && waarde.isNotEmpty) return waarde;
  }
  return _zoekToken(data['data']);
}

int? _zoekId(dynamic data) {
  if (data is! Map) return null;
  final waarde = data['id'] ?? data['teamId'];
  if (waarde is int) return waarde;
  if (waarde is String) return int.tryParse(waarde);
  return _zoekId(data['data'] ?? data['team']);
}
