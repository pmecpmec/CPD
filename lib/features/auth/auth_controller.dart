import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/repositories/auth_repository.dart';

/// In welke toestand de sessie verkeert.
enum SessieStatus {
  /// Nog aan het controleren of er een bewaarde sessie is.
  onbekend,
  uitgelogd,
  ingelogd,
}

/// Houdt de inlogstatus bij en voert de acties uit die daarbij horen.
///
/// De schermen luisteren naar deze klasse; ze praten niet zelf met de
/// repository. Zo staat de logica op één plek en is die apart te testen.
class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  SessieStatus _status = SessieStatus.onbekend;
  bool _bezig = false;
  String? _foutmelding;

  SessieStatus get status => _status;
  bool get bezig => _bezig;
  String? get foutmelding => _foutmelding;
  bool get isIngelogd => _status == SessieStatus.ingelogd;

  /// Wordt bij het opstarten aangeroepen: is er nog een geldige sessie?
  Future<void> herstelSessie() async {
    final aanwezig = await _repository.heeftSessie();
    _status = aanwezig ? SessieStatus.ingelogd : SessieStatus.uitgelogd;
    notifyListeners();
  }

  Future<bool> login({required String naam, required String wachtwoord}) =>
      _voerUit(() async {
        await _repository.login(naam: naam, wachtwoord: wachtwoord);
        _status = SessieStatus.ingelogd;
      });

  /// Registreert en logt daarna meteen in, zodat de gebruiker niet twee keer
  /// hetzelfde hoeft in te tikken.
  Future<bool> registreer({
    required String naam,
    required String wachtwoord,
  }) => _voerUit(() async {
    await _repository.registreer(naam: naam, wachtwoord: wachtwoord);
    await _repository.login(naam: naam, wachtwoord: wachtwoord);
    _status = SessieStatus.ingelogd;
  });

  Future<void> logout() async {
    await _repository.logout();
    _status = SessieStatus.uitgelogd;
    _foutmelding = null;
    notifyListeners();
  }

  /// Aangeroepen door de ApiClient wanneer de server een verlopen sessie meldt.
  void sessieVerlopen() {
    if (_status == SessieStatus.uitgelogd) return;
    _status = SessieStatus.uitgelogd;
    _foutmelding = const SessieVerlopenException().bericht;
    notifyListeners();
  }

  void wisFout() {
    if (_foutmelding == null) return;
    _foutmelding = null;
    notifyListeners();
  }

  /// Voert een actie uit en vertaalt fouten naar een melding voor het scherm.
  /// Geeft terug of het gelukt is.
  Future<bool> _voerUit(Future<void> Function() actie) async {
    _bezig = true;
    _foutmelding = null;
    notifyListeners();

    try {
      await actie();
      return true;
    } on AppException catch (e) {
      _foutmelding = e.bericht;
      return false;
    } catch (_) {
      _foutmelding = 'Er ging iets onverwachts mis. Probeer het opnieuw.';
      return false;
    } finally {
      _bezig = false;
      notifyListeners();
    }
  }
}
