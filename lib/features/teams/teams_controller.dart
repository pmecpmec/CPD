import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/team_repository.dart';

/// Houdt de teams van de gebruiker bij (FR-04, FR-05).
class TeamsController extends ChangeNotifier {
  TeamsController(this._repository);

  final TeamRepository _repository;

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
      _teams = await _repository.haalTeams();
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

  Future<bool> verlaatTeam(int teamId) async {
    try {
      await _repository.verlaatTeam(teamId);
      _teams = _teams.where((t) => t.id != teamId).toList();
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _foutmelding = e.bericht;
      notifyListeners();
      return false;
    }
  }
}
