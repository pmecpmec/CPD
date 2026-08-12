// Verkenningsscript voor de Team Management API.
//
// Draait de hele keten door — twee gebruikers registreren, inloggen, teams
// aanmaken, een lid toevoegen, een event en een match aanmaken, alles ophalen —
// en print bij elke stap de ruwe reactie. Daarmee staat zwart op wit hoe de
// antwoorden eruitzien, wat nodig is om de modellen in
// `lib/data/models/models.dart` te kunnen kloppen (taak T-01).
//
// Er zijn twee gebruikers nodig omdat een aantal vragen niet met één account te
// beantwoorden is: krijgt een lid dat géén eigenaar is een rol mee, en hoe ziet
// een uitnodiging eruit aan de kant van het uitgenodigde team.
//
// Draaien:
//   dart run tool/api_verkenning.dart
//
// De testgebruikers krijgen een willekeurige naam, zodat het script meerdere
// keren gedraaid kan worden zonder botsing. De uitvoer is ook bruikbaar als
// bijlage bij het testplan in het SDD; zie `docs/api-waargenomen-gedrag.md`.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

const basisUrl = 'https://team-managment-api.dendrowen.com/api/v2';

/// Lijsten van de API kunnen honderden items bevatten (`GET /teams` geeft álle
/// teams van de hele server). Voor het aflezen van de structuur is een paar
/// items genoeg; de rest wordt als aantal samengevat.
const maxLijstItems = 3;

String? _token;
final _client = http.Client();

Future<void> main() async {
  final suffix = Random().nextInt(999999).toString().padLeft(6, '0');
  final naamA = 'testuser${suffix}a';
  final naamB = 'testuser${suffix}b';
  const wachtwoord = 'TestWachtwoord123';

  stdout.writeln('Gebruiker A (beheerder): $naamA');
  stdout.writeln('Gebruiker B (lid):       $naamB');
  stdout.writeln('Basis-URL:               $basisUrl');

  try {
    // --- Gebruiker A ------------------------------------------------------
    await _stap(
      '1. Registreren gebruiker A',
      'POST',
      '/auth/register',
      body: {'name': naamA, 'password': wachtwoord},
    );

    final loginA = await _stap(
      '2. Inloggen gebruiker A',
      'POST',
      '/auth/login',
      body: {'name': naamA, 'password': wachtwoord},
    );
    final tokenA = _zoekToken(loginA);
    final userIdA = _zoekId(loginA);
    _token = tokenA;
    stdout.writeln(
      tokenA == null
          ? '   >> LET OP: geen token gevonden in het antwoord hierboven.'
          : '   >> Token gevonden, lengte ${tokenA.length}. userId: $userIdA',
    );

    await _stap(
      '3. Registreren met een bestaande naam (foutantwoord)',
      'POST',
      '/auth/register',
      body: {'name': naamA, 'password': wachtwoord},
    );

    // --- Gebruiker B ------------------------------------------------------
    await _stap(
      '4. Registreren gebruiker B',
      'POST',
      '/auth/register',
      body: {'name': naamB, 'password': wachtwoord},
    );

    final loginB = await _stap(
      '5. Inloggen gebruiker B',
      'POST',
      '/auth/login',
      body: {'name': naamB, 'password': wachtwoord},
    );
    final tokenB = _zoekToken(loginB);
    final userIdB = _zoekId(loginB);

    // Team van B, zodat er een tweede team is om voor een match uit te nodigen.
    _token = tokenB;
    final teamB = await _stap(
      '6. Team van gebruiker B aanmaken',
      'POST',
      '/teams',
      body: {
        'name': 'Testteam B $suffix',
        'description': 'Tegenstander voor de match',
        'metadata': {'Icon': 'shield'},
      },
    );
    final teamIdB = _zoekId(teamB);
    stdout.writeln('   >> teamId B: ${teamIdB ?? "niet gevonden"}');

    // --- Team van A -------------------------------------------------------
    _token = tokenA;
    final teamA = await _stap(
      '7. Team van gebruiker A aanmaken',
      'POST',
      '/teams',
      body: {
        'name': 'Testteam A $suffix',
        'description': 'Aangemaakt door het verkenningsscript',
        'metadata': {'Icon': 'calendar_today'},
      },
    );
    final teamIdA = _zoekId(teamA);
    stdout.writeln('   >> teamId A: ${teamIdA ?? "niet gevonden"}');

    await _stap('8. Alle teams ophalen', 'GET', '/teams');

    if (teamIdA == null) {
      stdout.writeln('\nGeen team-id gevonden; de rest wordt overgeslagen.');
      return;
    }

    await _stap('9. Eén team ophalen', 'GET', '/teams/$teamIdA');

    if (userIdB != null) {
      await _stap(
        '10. Gebruiker B aan team A toevoegen',
        'POST',
        '/teams/$teamIdA/addUser',
        body: {'userId': userIdB},
      );
      await _stap(
        '11. Team A opnieuw ophalen (twee leden: eigenaar en lid)',
        'GET',
        '/teams/$teamIdA',
      );
    }

    // --- Event ------------------------------------------------------------
    final nu = DateTime.now().toUtc();
    await _stap(
      '12. Event aanmaken',
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
        'teamId': teamIdA,
        'metadata': {'locatieNaam': 'Windesheim Almere'},
      },
    );

    await _stap('13. Events ophalen', 'GET', '/events');

    // --- Match ------------------------------------------------------------
    final match = await _stap(
      '14. Match aanmaken met team B uitgenodigd',
      'POST',
      '/matches',
      body: {
        'title': 'Testmatch',
        'description': 'Aangemaakt door het verkenningsscript',
        'datetimeStart': nu.add(const Duration(days: 2)).toIso8601String(),
        'datetimeEnd': nu
            .add(const Duration(days: 2, hours: 2))
            .toIso8601String(),
        'location': {'latitude': 52.5168, 'longitude': 5.4714},
        'teamId': teamIdA,
        'metadata': {'instructions': 'Neem je laptop mee'},
        'invites': [
          if (teamIdB != null) {'teamId': teamIdB},
        ],
      },
    );
    final matchId = _zoekId(match);
    stdout.writeln('   >> matchId: ${matchId ?? "niet gevonden"}');

    if (matchId != null) {
      await _stap('15. Eén match ophalen', 'GET', '/matches/$matchId');
    }

    await _stap('16. Matches ophalen als team A', 'GET', '/matches');
    await _stap(
      '17. Uitnodigingen ophalen als team A (uitnodigend team)',
      'GET',
      '/matches/invites',
    );

    // --- Uitgenodigde kant ------------------------------------------------
    _token = tokenB;
    final invites = await _stap(
      '18. Uitnodigingen ophalen als team B (uitgenodigd team)',
      'GET',
      '/matches/invites',
    );
    final inviteId = _zoekInviteId(invites, matchId);
    stdout.writeln('   >> inviteId: ${inviteId ?? "niet gevonden"}');

    if (inviteId != null) {
      await _stap(
        '19. Uitnodiging accepteren',
        'POST',
        '/matches/invites/$inviteId',
        body: {'status': 'accepted'},
      );
      if (matchId != null) {
        await _stap(
          '20. Match opnieuw ophalen na accepteren',
          'GET',
          '/matches/$matchId',
        );
      }
    }

    // --- Foutafhandeling --------------------------------------------------
    await _stap('21. Verlopen token', 'GET', '/dev/expired-token');
    await _stap('22. Onbekend team opvragen', 'GET', '/teams/99999999');
  } finally {
    _client.close();
  }

  stdout.writeln('\nKlaar. Uitvoer hoort in docs/api-waargenomen-gedrag.md.');
}

/// Voert één aanroep uit en print methode, pad, statuscode en het antwoord,
/// netjes ingesprongen zodat de structuur af te lezen is. Lange lijsten worden
/// afgekapt op [maxLijstItems]; de volledige structuur is dan nog steeds
/// zichtbaar zonder duizenden regels uitvoer.
Future<dynamic> _stap(
  String omschrijving,
  String methode,
  String pad, {
  Object? body,
}) async {
  stdout.writeln('\n${'-' * 70}');
  stdout.writeln('$omschrijving  ($methode $pad)');
  stdout.writeln('-' * 70);
  if (body != null) {
    stdout.writeln('Verzoek: ${jsonEncode(body)}');
  }

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
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert(_kapLijstenAf(data)),
    );
    return data;
  } on FormatException {
    stdout.writeln('(geen JSON)');
    stdout.writeln(antwoord.body);
    return null;
  }
}

/// Vervangt de staart van lange lijsten door een tekstregel met het aantal
/// overgeslagen items. Alleen voor het printen; de teruggegeven data blijft heel.
dynamic _kapLijstenAf(dynamic data) {
  if (data is List) {
    final zichtbaar = data.take(maxLijstItems).map(_kapLijstenAf).toList();
    if (data.length > maxLijstItems) {
      zichtbaar.add('... nog ${data.length - maxLijstItems} item(s), afgekapt');
    }
    return zichtbaar;
  }
  if (data is Map) {
    return data.map(
      (sleutel, waarde) => MapEntry(sleutel.toString(), _kapLijstenAf(waarde)),
    );
  }
  return data;
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

/// Zoekt in het antwoord van `GET /matches/invites` de uitnodiging die bij
/// [matchId] hoort en geeft het id terug waarmee die te accepteren is.
int? _zoekInviteId(dynamic data, int? matchId) {
  final lijst = data is Map ? data['data'] : data;
  if (lijst is! List) return null;
  for (final item in lijst.whereType<Map>()) {
    if (matchId == null || item['matchId'] == matchId) {
      final waarde = item['id'];
      if (waarde is int) return waarde;
      if (waarde is String) return int.tryParse(waarde);
    }
  }
  return null;
}
