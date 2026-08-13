import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config.dart';
import '../../core/errors.dart';
import 'token_store.dart';

/// Enige plek in de app waar HTTP-verkeer plaatsvindt.
///
/// Verantwoordelijkheden:
/// - de basis-URL voor elk verzoek zetten
/// - het toegangstoken meesturen zodra de gebruiker is ingelogd
/// - statuscodes vertalen naar de foutklassen uit `core/errors.dart`
///
/// Widgets roepen deze klasse niet rechtstreeks aan; dat loopt via de
/// repositories. Zie `CLAUDE.md`, regel 3.
class ApiClient {
  ApiClient({http.Client? httpClient, required this._tokenStore})
    : _http = httpClient ?? http.Client();

  final http.Client _http;
  final TokenStore _tokenStore;

  /// Wordt aangeroepen zodra de server aangeeft dat de sessie niet meer geldig
  /// is. De app kan hierop de gebruiker terugsturen naar het inlogscherm.
  void Function()? bijSessieVerlopen;

  Future<dynamic> get(String pad, {Map<String, String>? query}) =>
      _verstuur('GET', pad, query: query);

  Future<dynamic> post(String pad, {Object? body}) =>
      _verstuur('POST', pad, body: body);

  Future<dynamic> put(String pad, {Object? body}) =>
      _verstuur('PUT', pad, body: body);

  Future<dynamic> delete(String pad) => _verstuur('DELETE', pad);

  Future<dynamic> _verstuur(
    String methode,
    String pad, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}$pad',
    ).replace(queryParameters: query);

    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';

    final token = await _tokenStore.leesToken();
    final metToken = token != null && token.isNotEmpty;
    if (metToken) headers['Authorization'] = 'Bearer $token';

    late final http.Response antwoord;
    try {
      final verzoek = switch (methode) {
        'GET' => _http.get(uri, headers: headers),
        'POST' => _http.post(uri, headers: headers, body: jsonEncode(body)),
        'PUT' => _http.put(uri, headers: headers, body: jsonEncode(body)),
        'DELETE' => _http.delete(uri, headers: headers),
        _ => throw ArgumentError('Onbekende methode: $methode'),
      };
      antwoord = await verzoek.timeout(AppConfig.requestTimeout);
    } on TimeoutException {
      throw const NetwerkException(
        'De server reageerde niet op tijd. Probeer het opnieuw.',
      );
    } catch (_) {
      throw const NetwerkException();
    }

    return _verwerk(antwoord, metToken: metToken);
  }

  /// Vertaalt het HTTP-antwoord naar bruikbare data of naar een fout.
  ///
  /// De API verpakt élk antwoord in dezelfde envelop:
  /// `{"message": "Success", "data": {...}, "error": null}`, en bij een fout
  /// `{"message": "Error", "data": null, "error": ["..."]}`.
  /// Die envelop wordt hier uitgepakt, zodat de repositories alleen het echte
  /// object zien en niets van dit patroon hoeven te weten.
  dynamic _verwerk(http.Response antwoord, {required bool metToken}) {
    final code = antwoord.statusCode;

    if (code >= 200 && code < 300) {
      if (antwoord.body.isEmpty) return null;
      final dynamic data;
      try {
        data = jsonDecode(antwoord.body);
      } on FormatException {
        throw const ServerException('Onverwacht antwoord van de server.');
      }
      return _pakUit(data);
    }

    final melding = _serverMelding(antwoord.body);

    switch (code) {
      case 400:
      case 422:
        throw ValidatieException(
          melding ?? 'De ingevoerde gegevens kloppen niet.',
        );
      case 401:
        // Alleen een echt verlopen sessie melden. Een afgewezen inlogpoging
        // geeft ook 401, maar daar is nog geen sessie om te verliezen.
        if (metToken) bijSessieVerlopen?.call();
        throw SessieVerlopenException(
          melding ?? const SessieVerlopenException().bericht,
        );
      case 403:
        throw GeenRechtenException(
          melding ?? const GeenRechtenException().bericht,
        );
      case 404:
        throw const NietGevondenException();
      default:
        throw const ServerException();
    }
  }

  /// Haalt het `data`-veld uit de envelop. Antwoorden zonder envelop worden
  /// ongewijzigd doorgegeven, zodat een afwijkend endpoint niet stukloopt.
  dynamic _pakUit(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('data') &&
        data.containsKey('message')) {
      return data['data'];
    }
    return data;
  }

  /// Haalt de leesbare foutmelding uit het antwoord. De API zet die in
  /// `error`, een lijst met teksten; `message` bevat dan alleen "Error".
  ///
  /// Zie `docs/api-waargenomen-gedrag.md`, stap 3, 21 en 22: dat is de vorm die
  /// de server echt stuurt. De vormen die de documentatie noemt — dezelfde
  /// inhoud onder `errors`, of één losse tekst in plaats van een lijst — worden
  /// ook gelezen, zodat de melding niet verloren gaat als de server afwijkt.
  String? _serverMelding(String body) {
    if (body.isEmpty) return null;
    try {
      final data = jsonDecode(body);
      if (data is! Map<String, dynamic>) return null;

      for (final sleutel in const ['error', 'errors', 'detail']) {
        final melding = _leesFoutveld(data[sleutel]);
        if (melding != null) return melding;
      }

      final melding = data['message'];
      if (melding is String && melding.isNotEmpty && melding != 'Error') {
        return melding;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  /// Leest één foutveld: een losse tekst, of een lijst met teksten. Meerdere
  /// meldingen komen elk op een eigen regel, want ze achter elkaar plakken
  /// levert één onleesbare zin op. Levert `null` bij een leeg of afwijkend veld,
  /// zodat de aanroeper verder zoekt of op een algemene melding terugvalt.
  String? _leesFoutveld(dynamic waarde) {
    if (waarde is String) {
      final tekst = waarde.trim();
      return tekst.isEmpty ? null : tekst;
    }
    if (waarde is List) {
      final teksten = waarde
          .whereType<String>()
          .map((tekst) => tekst.trim())
          .where((tekst) => tekst.isNotEmpty);
      if (teksten.isEmpty) return null;
      return teksten.join('\n');
    }
    return null;
  }

  void sluit() => _http.close();
}
