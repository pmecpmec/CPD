import '../api/api_client.dart';
import '../models/models.dart';

/// Toegang tot matches en uitnodigingen (FR-15, FR-16).
///
/// Twee dingen uit `docs/api-waargenomen-gedrag.md`:
///
/// - `GET /matches` geeft alle matches op de server. Filteren is werk voor
///   de controller.
/// - Een match heeft geen statusveld. De status zit per uitnodiging in
///   `invites`. Het invite-id om te antwoorden komt alleen uit
///   `GET /matches/invites`, en dat endpoint levert alleen ontvangen
///   uitnodigingen.
abstract interface class MatchRepository {
  Future<List<Match>> haalMatches();
  Future<Match> haalMatch(int id);
  Future<Match> maakMatch({
    required int teamId,
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving,
    GeoLocatie? locatie,
    String? locatieNaam,
    required List<int> uitgenodigdeTeamIds,
  });
  Future<List<MatchInvite>> haalOntvangenUitnodigingen();
  Future<MatchInvite> beantwoordUitnodiging(int inviteId, InviteStatus status);
}

class ApiMatchRepository implements MatchRepository {
  ApiMatchRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Match>> haalMatches() async {
    final antwoord = await _client.get('/matches');
    if (antwoord is! List) return const [];
    return antwoord
        .whereType<Map>()
        .map((e) => Match.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Eén match op id. Let op: de teams in dit antwoord missen `ownerId`.
  @override
  Future<Match> haalMatch(int id) async {
    final antwoord = await _client.get('/matches/$id');
    return Match.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }

  @override
  Future<Match> maakMatch({
    required int teamId,
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving = '',
    GeoLocatie? locatie,
    String? locatieNaam,
    required List<int> uitgenodigdeTeamIds,
  }) async {
    final naam = locatieNaam?.trim();
    final antwoord = await _client.post(
      '/matches',
      body: {
        'title': titel,
        'description': beschrijving,
        'datetimeStart': start.toUtc().toIso8601String(),
        'datetimeEnd': eind.toUtc().toIso8601String(),
        if (locatie != null) 'location': locatie.toJson(),
        'teamId': teamId,
        'metadata': {'locatieNaam': ?naam},
        'invites': [
          for (final id in uitgenodigdeTeamIds) {'teamId': id},
        ],
      },
    );
    return Match.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }

  @override
  Future<List<MatchInvite>> haalOntvangenUitnodigingen() async {
    final antwoord = await _client.get('/matches/invites');
    if (antwoord is! List) return const [];
    return antwoord
        .whereType<Map>()
        .map((e) => MatchInvite.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<MatchInvite> beantwoordUitnodiging(
    int inviteId,
    InviteStatus status,
  ) async {
    final antwoord = await _client.post(
      '/matches/invites/$inviteId',
      body: {'status': _statusTekst(status)},
    );
    return MatchInvite.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }
}

String _statusTekst(InviteStatus status) => switch (status) {
  InviteStatus.pending => 'pending',
  InviteStatus.accepted => 'accepted',
  InviteStatus.declined => 'declined',
  InviteStatus.canceled => 'canceled',
};
