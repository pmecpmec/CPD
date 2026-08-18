import 'package:flutter/foundation.dart';

import '../../core/config.dart';
import '../../core/errors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/team_repository.dart';

/// Uitkomst van het verwerken van een gescande QR-code (FR-10).
sealed class QrScanVerwerking {
  const QrScanVerwerking();
}

/// De code voldeed niet aan `teamplanner:team:{id}`.
final class QrScanOngeldigeCode extends QrScanVerwerking {
  const QrScanOngeldigeCode();
}

/// Er loopt al een verwerking. Geen fout: de camera vuurt dezelfde code
/// tientallen keren per seconde.
final class QrScanBezig extends QrScanVerwerking {
  const QrScanBezig();
}

/// Het team-id uit de code bestaat niet (of is verwijderd).
final class QrScanNietGevonden extends QrScanVerwerking {
  const QrScanNietGevonden();

  String get melding => const NietGevondenException().bericht;
}

/// De gebruiker zat al in het team. Geen tweede addUser nodig.
final class QrScanAlLid extends QrScanVerwerking {
  const QrScanAlLid(this.team);

  final Team team;
}

/// De gebruiker is toegevoegd en ziet het team nu in het overzicht.
final class QrScanToegevoegd extends QrScanVerwerking {
  const QrScanToegevoegd(this.team);

  final Team team;
}

/// Een fout van de server of de sessie, met een tekst uit `errors.dart`.
final class QrScanMislukt extends QrScanVerwerking {
  const QrScanMislukt(this.melding);

  final String melding;
}

/// FR-10 — leest een gescande code en voegt de ingelogde gebruiker toe.
///
/// Volgorde: [TeamUitnodiging.leesTeamId] → [AuthRepository.huidigeGebruikerId]
/// → [TeamRepository.voegGebruikerToe]. Het scherm kent de `ApiClient` niet.
class QrScanController extends ChangeNotifier {
  QrScanController({
    required TeamRepository teamRepository,
    required AuthRepository authRepository,
  }) : _teams = teamRepository,
       _auth = authRepository;

  final TeamRepository _teams;
  final AuthRepository _auth;

  bool _bezig = false;

  bool get bezig => _bezig;

  /// Verwerkt één gescande [code]. Ongeldige codes en "team niet gevonden"
  /// komen als uitkomst terug, zodat de scanner open kan blijven.
  Future<QrScanVerwerking> verwerkCode(String? code) async {
    final teamId = TeamUitnodiging.leesTeamId(code);
    if (teamId == null) return const QrScanOngeldigeCode();
    if (_bezig) return const QrScanBezig();

    _bezig = true;
    notifyListeners();

    try {
      final gebruikerId = await _auth.huidigeGebruikerId();
      if (gebruikerId == null) {
        return QrScanMislukt(const SessieVerlopenException().bericht);
      }

      final team = await _teams.haalTeam(teamId);
      if (team.isLid(gebruikerId)) {
        return QrScanAlLid(team);
      }

      await _teams.voegGebruikerToe(teamId, gebruikerId);
      return QrScanToegevoegd(team);
    } on NietGevondenException {
      return const QrScanNietGevonden();
    } on AppException catch (e) {
      return QrScanMislukt(e.bericht);
    } catch (_) {
      return QrScanMislukt(const ServerException().bericht);
    } finally {
      _bezig = false;
      notifyListeners();
    }
  }
}
