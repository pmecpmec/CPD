import '../api/api_client.dart';
import '../models/models.dart';

/// Toegang tot matches (FR-13, FR-14). Aanmaken en beantwoorden volgt in T-10.
///
/// Twee dingen om te weten, beide gemeten in `docs/api-waargenomen-gedrag.md`:
///
/// - `GET /matches` geeft alle matches op de server, niet alleen die van de
///   eigen teams. Filteren op team-id is werk voor de controller.
/// - Een match heeft geen statusveld. De status zit per uitnodiging in
///   `Match.invites`. `Match.alleGeaccepteerd` en `Match.statusVoorTeam()`
///   leiden daar het antwoord uit af dat het rooster nodig heeft.
abstract interface class MatchRepository {
  Future<List<Match>> haalMatches();
  Future<Match> haalMatch(int id);
}

class ApiMatchRepository implements MatchRepository {
  ApiMatchRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Match>> haalMatches() async {
    // De ApiClient pakt de envelop uit, dus hier komt de lijst rechtstreeks.
    final antwoord = await _client.get('/matches');
    if (antwoord is! List) return const [];
    return antwoord
        .whereType<Map>()
        .map((e) => Match.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Eén match op id. Let op: de teams in dit antwoord missen `ownerId`,
  /// `description` en `metadata`, terwijl ze die in het lijstantwoord wel
  /// hebben. Baseer er geen rechten op; haal daarvoor het team los op.
  @override
  Future<Match> haalMatch(int id) async {
    final antwoord = await _client.get('/matches/$id');
    return Match.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }
}
