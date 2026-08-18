import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/team_repository.dart';
import '../events/event_form_controller.dart';

/// FR-15 — een beheerder maakt een match aan en nodigt andere teams uit.
class MatchFormController extends ChangeNotifier {
  MatchFormController({
    required MatchRepository matchRepository,
    required TeamRepository teamRepository,
    required AuthRepository authRepository,
    int? teamId,
    DateTime? nu,
  }) : _matches = matchRepository,
       _teams = teamRepository,
       _auth = authRepository,
       _nu = nu ?? DateTime.now() {
    _teamId = teamId;
    _begin = DateTime(_nu.year, _nu.month, _nu.day, _nu.hour + 1);
    _eind = _begin.add(EventFormController.standaardDuur);
  }

  final MatchRepository _matches;
  final TeamRepository _teams;
  final AuthRepository _auth;
  final DateTime _nu;

  int? _teamId;
  late DateTime _begin;
  late DateTime _eind;
  final Set<int> _uitgenodigd = {};
  List<Team> _alleTeams = const [];
  List<Team> _beheerTeams = const [];
  bool _laadt = false;
  bool _bezig = false;
  String? _foutmelding;

  int? get teamId => _teamId;
  DateTime get begin => _begin;
  DateTime get eind => _eind;
  Set<int> get uitgenodigd => Set.unmodifiable(_uitgenodigd);
  List<Team> get beheerTeams => _beheerTeams;
  List<Team> get andereTeams =>
      _alleTeams.where((team) => team.id != _teamId).toList();
  bool get laadt => _laadt;
  bool get bezig => _bezig;
  String? get foutmelding => _foutmelding;

  DateTime get vroegsteDatum => DateTime(_nu.year - 1);
  DateTime get laatsteDatum => DateTime(_nu.year + 5, 12, 31);

  String? get periodeFout =>
      _eind.isAfter(_begin) ? null : 'De eindtijd moet ná de begintijd liggen.';

  String? get teamsFout =>
      _uitgenodigd.isEmpty ? 'Nodig minstens één ander team uit.' : null;

  Future<void> laad() async {
    _laadt = true;
    _foutmelding = null;
    notifyListeners();

    try {
      final gebruikerId = await _auth.huidigeGebruikerId();
      _alleTeams = await _teams.haalTeams();
      _beheerTeams = _alleTeams
          .where((team) => team.isBeheerder(gebruikerId))
          .toList();
      _teamId ??= _beheerTeams.isEmpty ? null : _beheerTeams.first.id;
    } on AppException catch (e) {
      _foutmelding = e.bericht;
    } catch (_) {
      _foutmelding = const ServerException().bericht;
    } finally {
      _laadt = false;
      notifyListeners();
    }
  }

  void zetTeam(int id) {
    _teamId = id;
    _uitgenodigd.remove(id);
    notifyListeners();
  }

  void zetBegin(DateTime moment) {
    _begin = moment;
    notifyListeners();
  }

  void zetEind(DateTime moment) {
    _eind = moment;
    notifyListeners();
  }

  void zetUitnodiging(int teamId, bool gekozen) {
    if (gekozen) {
      _uitgenodigd.add(teamId);
    } else {
      _uitgenodigd.remove(teamId);
    }
    notifyListeners();
  }

  Future<Match?> maakMatch({
    required String titel,
    required String beschrijving,
    required String breedtegraad,
    required String lengtegraad,
    required String locatieNaam,
  }) async {
    if (_bezig) return null;
    if (_teamId == null || periodeFout != null || teamsFout != null) {
      _foutmelding = periodeFout ?? teamsFout;
      notifyListeners();
      return null;
    }

    _bezig = true;
    _foutmelding = null;
    notifyListeners();

    try {
      final naam = locatieNaam.trim();
      return await _matches.maakMatch(
        teamId: _teamId!,
        titel: titel.trim(),
        beschrijving: beschrijving.trim(),
        start: _begin,
        eind: _eind,
        locatie: _leesLocatie(breedtegraad, lengtegraad),
        locatieNaam: naam.isEmpty ? null : naam,
        uitgenodigdeTeamIds: _uitgenodigd.toList(),
      );
    } on AppException catch (e) {
      _foutmelding = e.bericht;
      return null;
    } catch (_) {
      _foutmelding = const ServerException().bericht;
      return null;
    } finally {
      _bezig = false;
      notifyListeners();
    }
  }

  GeoLocatie? _leesLocatie(String breedtegraad, String lengtegraad) {
    final noord = leesCoordinaat(breedtegraad);
    final oost = leesCoordinaat(lengtegraad);
    if (noord == null || oost == null) return null;
    return GeoLocatie(latitude: noord, longitude: oost);
  }
}
