/// Centrale configuratie van de applicatie.
///
/// De basis-URL staat hier en nergens anders, zodat er in tests of bij een
/// andere omgeving maar één plek gewijzigd hoeft te worden.
class AppConfig {
  const AppConfig._();

  /// Basis-URL van de Team Management API, versie 2.
  static const String apiBaseUrl =
      'https://team-managment-api.dendrowen.com/api/v2';

  /// Maximale wachttijd op een antwoord van de server.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Sleutel waaronder het toegangstoken veilig wordt opgeslagen.
  static const String tokenStorageKey = 'auth_token';

  /// Sleutel waaronder het id van de ingelogde gebruiker wordt opgeslagen.
  static const String userIdStorageKey = 'user_id';
}
