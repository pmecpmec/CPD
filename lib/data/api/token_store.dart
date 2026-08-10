import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config.dart';

/// Bewaarplaats voor het toegangstoken.
///
/// Achter een interface gezet zodat er in tests een eenvoudige variant in de
/// plaats kan, zonder platformafhankelijke opslag (NFR-06).
abstract interface class TokenStore {
  Future<String?> leesToken();
  Future<void> schrijfToken(String token);
  Future<int?> leesGebruikerId();
  Future<void> schrijfGebruikerId(int id);
  Future<void> wisAlles();
}

/// Implementatie op basis van de beveiligde opslag van het platform:
/// Keystore op Android, en op web een versleutelde vorm van localStorage.
/// Het token komt daarmee nooit in de broncode of in gewone voorkeuren (NFR-04).
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? opslag])
    : _opslag = opslag ?? const FlutterSecureStorage();

  final FlutterSecureStorage _opslag;

  @override
  Future<String?> leesToken() => _opslag.read(key: AppConfig.tokenStorageKey);

  @override
  Future<void> schrijfToken(String token) =>
      _opslag.write(key: AppConfig.tokenStorageKey, value: token);

  @override
  Future<int?> leesGebruikerId() async {
    final waarde = await _opslag.read(key: AppConfig.userIdStorageKey);
    if (waarde == null) return null;
    return int.tryParse(waarde);
  }

  @override
  Future<void> schrijfGebruikerId(int id) =>
      _opslag.write(key: AppConfig.userIdStorageKey, value: '$id');

  @override
  Future<void> wisAlles() async {
    await _opslag.delete(key: AppConfig.tokenStorageKey);
    await _opslag.delete(key: AppConfig.userIdStorageKey);
  }
}

/// Eenvoudige variant zonder platformafhankelijkheden, bedoeld voor tests.
class GeheugenTokenStore implements TokenStore {
  String? _token;
  int? _gebruikerId;

  @override
  Future<String?> leesToken() async => _token;

  @override
  Future<void> schrijfToken(String token) async => _token = token;

  @override
  Future<int?> leesGebruikerId() async => _gebruikerId;

  @override
  Future<void> schrijfGebruikerId(int id) async => _gebruikerId = id;

  @override
  Future<void> wisAlles() async {
    _token = null;
    _gebruikerId = null;
  }
}
