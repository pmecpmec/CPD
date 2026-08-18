import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/team_repository.dart';
import 'invite_overgangen.dart';

/// Eén ontvangen uitnodiging met de match erbij, voor zover bekend.
class OntvangenUitnodiging {
  const OntvangenUitnodiging({required this.invite, this.match});

  final MatchInvite invite;
  final Match? match;

  String get titel => match?.title ?? 'Match ${invite.matchId ?? invite.id}';

  List<InviteStatus> get overgangen =>
      toegestaneInviteOvergangen(invite.status);
}

/// FR-16 — openstaande en geaccepteerde uitnodigingen van de gebruiker.
class MatchInvitesController extends ChangeNotifier {
  MatchInvitesController({
    required MatchRepository matchRepository,
    required TeamRepository teamRepository,
    required AuthRepository authRepository,
  }) : _matches = matchRepository,
       _teams = teamRepository,
       _auth = authRepository;

  final MatchRepository _matches;
  final TeamRepository _teams;
  final AuthRepository _auth;

  List<OntvangenUitnodiging> _items = const [];
  List<Team> _beheerTeams = const [];
  bool _laadt = false;
  bool _bezig = false;
  String? _foutmelding;

  List<OntvangenUitnodiging> get items => _items;
  List<Team> get beheerTeams => _beheerTeams;
  bool get laadt => _laadt;
  bool get bezig => _bezig;
  String? get foutmelding => _foutmelding;
  bool get isLeeg => !_laadt && _foutmelding == null && _items.isEmpty;
  bool get magMatchAanmaken => _beheerTeams.isNotEmpty;

  Future<void> laad() async {
    _laadt = true;
    _foutmelding = null;
    notifyListeners();

    try {
      final gebruikerId = await _auth.huidigeGebruikerId();
      final resultaten = await Future.wait([
        _matches.haalOntvangenUitnodigingen(),
        _matches.haalMatches(),
        _teams.haalTeams(),
      ]);
      final invites = resultaten[0] as List<MatchInvite>;
      final matches = resultaten[1] as List<Match>;
      final teams = resultaten[2] as List<Team>;

      final matchOpId = {for (final match in matches) match.id: match};
      _beheerTeams = teams
          .where((team) => team.isBeheerder(gebruikerId))
          .toList();
      _items = [
        for (final invite in invites)
          OntvangenUitnodiging(
            invite: invite,
            match: invite.matchId == null ? null : matchOpId[invite.matchId],
          ),
      ];
    } on AppException catch (e) {
      _foutmelding = e.bericht;
    } catch (_) {
      _foutmelding = const ServerException().bericht;
    } finally {
      _laadt = false;
      notifyListeners();
    }
  }

  Future<bool> beantwoord(OntvangenUitnodiging item, InviteStatus naar) async {
    final inviteId = item.invite.id;
    if (inviteId == null) return false;
    if (!magInviteOvergang(item.invite.status, naar) || _bezig) return false;

    _bezig = true;
    _foutmelding = null;
    notifyListeners();

    try {
      await _matches.beantwoordUitnodiging(inviteId, naar);
      await laad();
      return true;
    } on AppException catch (e) {
      _foutmelding = e.bericht;
      return false;
    } catch (_) {
      _foutmelding = const ServerException().bericht;
      return false;
    } finally {
      _bezig = false;
      notifyListeners();
    }
  }
}
