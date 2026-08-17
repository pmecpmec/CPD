import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/team_repository.dart';
import 'rooster.dart';

/// Logica achter het persoonlijk rooster (FR-14).
///
/// Events komen uit `GET /events`, dat al alle teams van de gebruiker dekt.
/// Matches komen uit `GET /matches`, dat alles van de server geeft. Filteren
/// op lidmaatschap, ontdubbelen op match-id en sorteren gebeurt hier.
class MyScheduleController extends ChangeNotifier {
  MyScheduleController({
    required EventRepository eventRepository,
    required MatchRepository matchRepository,
    required TeamRepository teamRepository,
    required AuthRepository authRepository,
    DateTime Function()? klok,
  }) : _events = eventRepository,
       _matches = matchRepository,
       _teams = teamRepository,
       _auth = authRepository,
       _klok = klok ?? DateTime.now;

  final EventRepository _events;
  final MatchRepository _matches;
  final TeamRepository _teams;
  final AuthRepository _auth;
  final DateTime Function() _klok;

  RoosterVerdeling _verdeling = const RoosterVerdeling(
    toekomst: [],
    verleden: [],
  );
  bool _laadt = false;
  bool _geladen = false;
  String? _foutmelding;

  RoosterVerdeling get verdeling => _verdeling;
  bool get laadt => _laadt;
  String? get foutmelding => _foutmelding;

  bool get isLeeg => _geladen && _foutmelding == null && _verdeling.isLeeg;

  /// Maakt het rooster leeg, zodat een volgende gebruiker niet even de agenda
  /// van de vorige ziet.
  void wis() {
    _verdeling = const RoosterVerdeling(toekomst: [], verleden: []);
    _foutmelding = null;
    _laadt = false;
    _geladen = false;
    notifyListeners();
  }

  Future<void> laad() async {
    _laadt = true;
    _foutmelding = null;
    notifyListeners();

    try {
      final gebruikerId = await _auth.huidigeGebruikerId();
      final alleTeams = await _teams.haalTeams();
      final eigenIds = alleTeams
          .where((team) => team.isLid(gebruikerId))
          .map((team) => team.id)
          .toSet();

      final events = await _events.haalEvents();
      final matches = await _matches.haalMatches();

      // Per betrokken team een regel, daarna ontdubbelen op match-id. Zo
      // blijven beide teamnamen bewaard wanneer de gebruiker via twee teams
      // bij dezelfde match hoort (FR-14).
      final items = [
        for (final event in events) RoosterItem.vanEvent(event),
        for (final match in matches)
          for (final teamId in match.teamIds)
            if (eigenIds.contains(teamId))
              RoosterItem(
                soort: RoosterSoort.match,
                id: match.id,
                titel: match.title,
                start: match.start,
                eind: match.end,
                teamNamen: [?matchTeamNaam(match, teamId)],
                statusLabel: matchStatusLabel(match, {teamId}),
              ),
      ];

      _verdeling = verdeelRooster(ontdubbelRoosterItems(items), nu: _klok());
      _geladen = true;
    } on AppException catch (e) {
      _foutmelding = e.bericht;
    } catch (_) {
      _foutmelding = const ServerException().bericht;
    } finally {
      _laadt = false;
      notifyListeners();
    }
  }
}
