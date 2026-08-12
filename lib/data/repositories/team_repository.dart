import '../api/api_client.dart';
import '../models/models.dart';

/// Toegang tot teams en teamleden (FR-04 tot en met FR-08).
abstract interface class TeamRepository {
  Future<List<Team>> haalTeams();
  Future<Team> haalTeam(int id);
  Future<Team> maakTeam({
    required String naam,
    String beschrijving,
    String? iconNaam,
  });
  Future<Team> wijzigTeam(
    int id, {
    required String naam,
    required String beschrijving,
  });
  Future<void> verwijderTeam(int id);
  Future<void> voegGebruikerToe(int teamId, int userId);
  Future<void> verwijderGebruiker(int teamId, int userId);
  Future<void> verlaatTeam(int teamId);
}

class ApiTeamRepository implements TeamRepository {
  ApiTeamRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Team>> haalTeams() async {
    final antwoord = await _client.get('/teams');
    final lijst = antwoord is List ? antwoord : (antwoord?['data'] as List?);
    if (lijst == null) return const [];
    return lijst
        .whereType<Map>()
        .map((e) => Team.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<Team> haalTeam(int id) async {
    final antwoord = await _client.get('/teams/$id');
    return Team.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }

  @override
  Future<Team> maakTeam({
    required String naam,
    String beschrijving = '',
    String? iconNaam,
  }) async {
    final antwoord = await _client.post(
      '/teams',
      body: {
        'name': naam,
        'description': beschrijving,
        'metadata': {'Icon': ?iconNaam},
      },
    );
    return Team.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }

  @override
  Future<Team> wijzigTeam(
    int id, {
    required String naam,
    required String beschrijving,
  }) async {
    final antwoord = await _client.put(
      '/teams/$id',
      body: {'name': naam, 'description': beschrijving},
    );
    return Team.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }

  @override
  Future<void> verwijderTeam(int id) => _client.delete('/teams/$id');

  @override
  Future<void> voegGebruikerToe(int teamId, int userId) =>
      _client.post('/teams/$teamId/addUser', body: {'userId': userId});

  @override
  Future<void> verwijderGebruiker(int teamId, int userId) =>
      _client.post('/teams/$teamId/removeUser', body: {'userId': userId});

  @override
  Future<void> verlaatTeam(int teamId) =>
      _client.post('/teams/$teamId/leave', body: const {});
}
