import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/team_repository.dart';

/// Wat er met het team is gebeurd terwijl het detailscherm openstond.
///
/// Het scherm geeft dit mee bij het sluiten, zodat het overzicht weet dat het
/// zichzelf moet verversen en welke melding erbij hoort (FR-07, FR-08).
enum TeamDetailUitkomst { verlaten, verwijderd }

/// Logica achter het teamdetailscherm (FR-06, FR-07, FR-08).
///
/// Twee dingen bepalen wat de gebruiker mag zien en doen, en beide komen hier
/// vandaan — niet uit de widget:
///
/// - **Lidmaatschap.** `GET /teams` en `GET /teams/{id}` geven de volledige
///   inhoud van élk team op de server, ook aan iemand die er niet bij hoort
///   (zie `docs/api-waargenomen-gedrag.md`). De privacy-eis uit FR-06 dwingt
///   de app dus zelf af: [leden] is leeg zolang [isLid] onwaar is.
/// - **Rol.** De API kent geen rol per lid; de beheerder is de gebruiker in
///   `Team.ownerId`. Dat oordeel staat in [Team.isBeheerder] en wordt hier
///   niet overgedaan.
///
/// Het team wordt altijd los opgehaald met `GET /teams/{id}`. Een team dat als
/// bijlage bij een match meekomt mist `ownerId`, en op zo'n antwoord mogen geen
/// rechten worden gebaseerd.
class TeamDetailController extends ChangeNotifier {
  TeamDetailController({
    required TeamRepository teamRepository,
    required AuthRepository authRepository,
    required this.teamId,
    this.bekendTeam,
  }) : _teams = teamRepository,
       _auth = authRepository;

  final TeamRepository _teams;
  final AuthRepository _auth;

  final int teamId;

  /// Wat het overzicht al van dit team wist. Alleen gebruikt om naam en
  /// omschrijving te tonen terwijl het echte antwoord onderweg is; rechten
  /// worden er nooit op gebaseerd, want een team uit een lijstantwoord kan
  /// velden missen.
  final Team? bekendTeam;

  Team? _team;
  int? _gebruikerId;
  bool _laadt = false;
  bool _bezig = false;
  String? _foutmelding;

  Team? get team => _team;
  bool get laadt => _laadt;

  /// Er loopt een actie die het team verandert; knoppen horen dan uit te staan.
  bool get bezig => _bezig;

  String? get foutmelding => _foutmelding;

  String get naam => _team?.name ?? bekendTeam?.name ?? '';
  String get omschrijving =>
      _team?.description ?? bekendTeam?.description ?? '';

  /// Is de ingelogde gebruiker de beheerder van dit team?
  bool get isBeheerder => _team?.isBeheerder(_gebruikerId) ?? false;

  /// Hoort de ingelogde gebruiker bij dit team? Bepaalt wat zichtbaar is
  /// (FR-06).
  bool get isLid => _team?.isLid(_gebruikerId) ?? false;

  /// De ledenlijst, of leeg voor wie geen lid is (FR-06).
  List<User> get leden => isLid ? (_team?.members ?? const []) : const [];

  /// Mag de gebruiker dit team verlaten? Een beheerder niet: die kan het team
  /// alleen verwijderen (FR-07). De API bevestigt dat en antwoordt met
  /// "The team owner cannot remove themselves from the team".
  bool get magVertrekken => isLid && !isBeheerder;

  /// Is [lid] de beheerder? Voor het merkje in de ledenlijst.
  bool isBeheerderVan(User lid) => _team?.isBeheerder(lid.id) ?? false;

  /// Is [lid] de ingelogde gebruiker zelf?
  bool isJezelf(User lid) => lid.id == _gebruikerId;

  Future<void> laad() async {
    _laadt = true;
    _foutmelding = null;
    notifyListeners();

    try {
      _gebruikerId = await _auth.huidigeGebruikerId();
      _team = await _teams.haalTeam(teamId);
    } on AppException catch (e) {
      _foutmelding = e.bericht;
    } catch (_) {
      _foutmelding = 'Het team kon niet worden opgehaald.';
    } finally {
      _laadt = false;
      notifyListeners();
    }
  }

  /// Verwijdert een lid uit het team (FR-08). De API geeft het bijgewerkte
  /// team terug, dus een extra ophaalronde is niet nodig.
  Future<bool> verwijderLid(int userId) => _voerUit(() async {
    _team = await _teams.verwijderGebruiker(teamId, userId);
  });

  /// De gebruiker verlaat het team zelf (FR-07).
  Future<bool> verlaatTeam() => _voerUit(() => _teams.verlaatTeam(teamId));

  /// De beheerder verwijdert het hele team (FR-07: de enige uitweg voor een
  /// beheerder, want vertrekken kan hij niet).
  Future<bool> verwijderTeam() => _voerUit(() => _teams.verwijderTeam(teamId));

  /// Voert een actie uit en vertaalt een fout naar een melding voor het scherm.
  Future<bool> _voerUit(Future<void> Function() actie) async {
    if (_bezig) return false;
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
