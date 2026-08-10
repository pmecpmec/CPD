import '../../core/errors.dart';
import '../api/api_client.dart';
import '../api/token_store.dart';

/// Toegang tot registratie, inloggen en de sessie (FR-01, FR-02, FR-03).
abstract interface class AuthRepository {
  Future<void> registreer({required String naam, required String wachtwoord});
  Future<void> login({required String naam, required String wachtwoord});
  Future<void> logout();

  /// Of er bij het opstarten al een geldige sessie bewaard is.
  Future<bool> heeftSessie();

  /// Id van de ingelogde gebruiker, nodig om jezelf aan een team toe te voegen.
  Future<int?> huidigeGebruikerId();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required ApiClient client, required TokenStore tokenStore})
    : _client = client,
      _tokenStore = tokenStore;

  final ApiClient _client;
  final TokenStore _tokenStore;

  @override
  Future<void> registreer({
    required String naam,
    required String wachtwoord,
  }) async {
    await _client.post(
      '/auth/register',
      body: {'name': naam, 'password': wachtwoord},
    );
  }

  @override
  Future<void> login({
    required String naam,
    required String wachtwoord,
  }) async {
    final dynamic antwoord;
    try {
      antwoord = await _client.post(
        '/auth/login',
        body: {'name': naam, 'password': wachtwoord},
      );
    } on SessieVerlopenException {
      // De API antwoordt met 401 bij verkeerde inloggegevens. Dat is hier geen
      // verlopen sessie maar een afgewezen poging.
      throw const OngeldigeInlogException();
    }

    if (antwoord is! Map<String, dynamic>) {
      throw const ServerException('Onverwacht antwoord bij het inloggen.');
    }

    final token = _zoekToken(antwoord);
    if (token == null) {
      throw const ServerException(
        'De server stuurde geen toegangstoken terug.',
      );
    }
    await _tokenStore.schrijfToken(token);

    final id = _zoekGebruikerId(antwoord);
    if (id != null) await _tokenStore.schrijfGebruikerId(id);
  }

  @override
  Future<void> logout() => _tokenStore.wisAlles();

  @override
  Future<bool> heeftSessie() async {
    final token = await _tokenStore.leesToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<int?> huidigeGebruikerId() => _tokenStore.leesGebruikerId();

  /// De documentatie legt de naam van het tokenveld niet vast. Deze functie
  /// probeert de gangbare varianten. Zodra het echte antwoord bekend is, mag
  /// dit vereenvoudigd worden tot de ene juiste sleutel.
  String? _zoekToken(Map<String, dynamic> data) {
    for (final sleutel in ['token', 'accessToken', 'access_token', 'jwt']) {
      final waarde = data[sleutel];
      if (waarde is String && waarde.isNotEmpty) return waarde;
    }
    final genest = data['data'];
    if (genest is Map<String, dynamic>) return _zoekToken(genest);
    return null;
  }

  int? _zoekGebruikerId(Map<String, dynamic> data) {
    for (final sleutel in ['userId', 'user_id', 'id']) {
      final waarde = data[sleutel];
      if (waarde is int) return waarde;
      if (waarde is String) return int.tryParse(waarde);
    }
    final gebruiker = data['user'];
    if (gebruiker is Map<String, dynamic>) return _zoekGebruikerId(gebruiker);
    return null;
  }
}
