import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/match_repository.dart';
import 'rooster.dart';

/// Logica achter het teamrooster (FR-13).
///
/// Het rooster wordt uit twee bronnen samengesteld, want de API heeft er geen
/// endpoint voor: `GET /events` levert de events van alle teams van de
/// gebruiker en `GET /matches` levert alle matches op de server. Filteren op
/// dit ene team is dus werk voor de app. Zie `docs/api-waargenomen-gedrag.md`,
/// stap 13 en 16.
class TeamScheduleController extends ChangeNotifier {
  TeamScheduleController({
    required EventRepository eventRepository,
    required MatchRepository matchRepository,
    required this.teamId,
    DateTime Function()? klok,
  }) : _events = eventRepository,
       _matches = matchRepository,
       _klok = klok ?? DateTime.now;

  final EventRepository _events;
  final MatchRepository _matches;

  final int teamId;

  /// Waar "nu" vandaan komt. Injecteerbaar, zodat een test de scheiding tussen
  /// verleden en toekomst kan vastzetten.
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

  /// Er is opgehaald en er staat niets gepland. Pas dan is de lege staat waar
  /// (FR-13); tijdens het eerste laden is er alleen nog niets bekend.
  bool get isLeeg => _geladen && _foutmelding == null && _verdeling.isLeeg;

  Future<void> laad() async {
    _laadt = true;
    _foutmelding = null;
    notifyListeners();

    try {
      // Na elkaar, niet met `.wait`: die bundelt een fout in een
      // `ParallelWaitError` en dan raakt de melding uit `core/errors.dart`
      // zoek, terwijl de gebruiker juist die hoort te zien (NFR-03).
      final events = await _events.haalEvents();
      final matches = await _matches.haalMatches();

      final items = [
        for (final event in events)
          if (event.teamId == teamId) RoosterItem.vanEvent(event),
        for (final match in matches)
          if (match.teamIds.contains(teamId))
            RoosterItem.vanMatch(match, eigenTeamIds: {teamId}),
      ];

      _verdeling = verdeelRooster(items, nu: _klok());
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
