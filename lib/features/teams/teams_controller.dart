import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/team_repository.dart';

/// Houdt de teams van de gebruiker bij (FR-04, FR-05).
class TeamsController extends ChangeNotifier {
  TeamsController(this._repository, this._auth);

  final TeamRepository _repository;
  final AuthRepository _auth;

  List<Team> _teams = const [];
  bool _laadt = false;
  String? _foutmelding;

  List<Team> get teams => _teams;
  bool get laadt => _laadt;
  String? get foutmelding => _foutmelding;
  bool get isLeeg => !_laadt && _foutmelding == null && _teams.isEmpty;

  Future<void> laad() async {
    _laadt = true;
    _foutmelding = null;
    notifyListeners();

    try {
      // `GET /teams` geeft álle teams van de hele server terug, ook die van
      // andere gebruikers (zie docs/api-waargenomen-gedrag.md). Het overzicht
      // toont alleen de teams waar de gebruiker bij hoort (FR-05, FR-06) —
      // en zonder dit filter zou een verlaten team bij de eerstvolgende
      // verversing weer opduiken (FR-07).
      final gebruikerId = await _auth.huidigeGebruikerId();
      final alleTeams = await _repository.haalTeams();
      _teams = alleTeams.where((team) => team.isLid(gebruikerId)).toList();
    } on AppException catch (e) {
      _foutmelding = e.bericht;
    } catch (_) {
      _foutmelding = 'De teams konden niet worden opgehaald.';
    } finally {
      _laadt = false;
      notifyListeners();
    }
  }

  /// Maakt een team aan en zet het meteen in de lijst, zodat de gebruiker het
  /// resultaat ziet zonder op een nieuwe ronde langs de server te wachten.
  Future<bool> maakTeam({
    required String naam,
    String beschrijving = '',
  }) async {
    try {
      final team = await _repository.maakTeam(
        naam: naam,
        beschrijving: beschrijving,
      );
      _teams = [..._teams, team];
      _foutmelding = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _foutmelding = e.bericht;
      notifyListeners();
      return false;
    }
  }
}
