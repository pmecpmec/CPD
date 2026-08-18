import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/teams/teams_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testdubbel zonder netwerk. Geeft één team terug waarvan gebruiker 1 lid is.
class NepTeamRepository implements TeamRepository {
  NepTeamRepository({this.fout});

  final AppException? fout;

  static const team = Team(
    id: 1,
    name: 'Herstelteam',
    description: 'Testdesc',
    ownerId: 1,
    members: [User(id: 1, name: 'hr17014445')],
  );

  @override
  Future<List<Team>> haalTeams() async {
    if (fout != null) throw fout!;
    return const [team];
  }

  @override
  Future<Team> haalTeam(int id) async => team;

  @override
  Future<Team> maakTeam({
    required String naam,
    String beschrijving = '',
    String? iconNaam,
  }) async => team;

  @override
  Future<Team> wijzigTeam(
    int id, {
    required String naam,
    required String beschrijving,
  }) async => team;

  @override
  Future<void> verwijderTeam(int id) async {}

  @override
  Future<void> voegGebruikerToe(int teamId, int userId) async {}

  @override
  Future<Team> verwijderGebruiker(int teamId, int userId) async => team;

  @override
  Future<void> verlaatTeam(int teamId) async {}
}

class NepAuthRepository implements AuthRepository {
  @override
  Future<int?> huidigeGebruikerId() async => 1;

  @override
  Future<bool> heeftSessie() async => true;

  @override
  Future<void> login({
    required String naam,
    required String wachtwoord,
  }) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> registreer({
    required String naam,
    required String wachtwoord,
  }) async {}
}

void main() {
  test('wis maakt de lijst en de foutmelding leeg', () async {
    final controller = TeamsController(
      NepTeamRepository(),
      NepAuthRepository(),
    );
    await controller.laad();

    expect(controller.teams, isNotEmpty, reason: 'eerst moet er iets in staan');
    expect(controller.foutmelding, isNull);

    controller.wis();

    expect(controller.teams, isEmpty);
    expect(controller.foutmelding, isNull);
    expect(controller.laadt, isFalse);
  });

  test('wis wist ook een eerdere foutmelding', () async {
    final controller = TeamsController(
      NepTeamRepository(fout: const NetwerkException()),
      NepAuthRepository(),
    );
    await controller.laad();

    expect(controller.foutmelding, isNotNull);
    expect(controller.teams, isEmpty);

    controller.wis();

    expect(controller.teams, isEmpty);
    expect(controller.foutmelding, isNull);
  });
}
