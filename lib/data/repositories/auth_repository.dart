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
  ApiAuthRepository({required this._client, required this._tokenStore});

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
  Future<void> login({required String naam, required String wachtwoord}) async {
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

    // De ApiClient heeft de envelop al uitgepakt, dus hier staat het
    // `data`-object: {"id": 1, "name": "pedro", "token": "eyJ..."}.
    if (antwoord is! Map<String, dynamic>) {
      throw const ServerException('Onverwacht antwoord bij het inloggen.');
    }

    final token = antwoord['token'];
    if (token is! String || token.isEmpty) {
      throw const ServerException(
        'De server stuurde geen toegangstoken terug.',
      );
    }
    await _tokenStore.schrijfToken(token);

    final id = antwoord['id'];
    if (id is int) {
      await _tokenStore.schrijfGebruikerId(id);
    } else if (id is String) {
      final gelezen = int.tryParse(id);
      if (gelezen != null) await _tokenStore.schrijfGebruikerId(gelezen);
    }
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
}
