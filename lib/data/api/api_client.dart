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
    if (token != null && token.isNotEmpty) {
      // Aangenomen schema is Bearer, wat de Authorize-knop in de Swagger-pagina
      // suggereert. Controleer dit bij de eerste aanroep tegen de echte API en
      // pas het hier aan als het anders blijkt te zijn.
      headers['Authorization'] = 'Bearer $token';
    }

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

    return _verwerk(antwoord);
  }

  dynamic _verwerk(http.Response antwoord) {
    final code = antwoord.statusCode;

    if (code >= 200 && code < 300) {
      if (antwoord.body.isEmpty) return null;
      try {
        return jsonDecode(antwoord.body);
      } on FormatException {
        throw const ServerException('Onverwacht antwoord van de server.');
      }
    }

    final melding = _serverMelding(antwoord.body);

    switch (code) {
      case 400:
      case 422:
        throw ValidatieException(
          melding ?? 'De ingevoerde gegevens kloppen niet.',
        );
      case 401:
        bijSessieVerlopen?.call();
        throw const SessieVerlopenException();
      case 403:
        throw const GeenRechtenException();
      case 404:
        throw const NietGevondenException();
      default:
        throw const ServerException();
    }
  }

  /// Haalt indien mogelijk een leesbare melding uit het antwoord van de server.
  String? _serverMelding(String body) {
    if (body.isEmpty) return null;
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        for (final sleutel in ['message', 'error', 'detail']) {
          final waarde = data[sleutel];
          if (waarde is String && waarde.isNotEmpty) return waarde;
        }
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  void sluit() => _http.close();
}
