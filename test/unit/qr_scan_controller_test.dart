import 'dart:async';

import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/teams/qr_scan_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NepTeamRepository teams;
  late NepAuthRepository auth;
  late QrScanController controller;

  setUp(() {
    teams = NepTeamRepository();
    auth = NepAuthRepository();
    controller = QrScanController(teamRepository: teams, authRepository: auth);
  });

  test('ongeldige code gaat niet naar de repository', () async {
    final uitkomst = await controller.verwerkCode('https://voorbeeld.nl');

    expect(uitkomst, isA<QrScanOngeldigeCode>());
    expect(teams.opgehaaldeIds, isEmpty);
    expect(teams.toegevoegde, isEmpty);
  });

  test('voegt de huidige gebruiker toe na een geldige code', () async {
    teams.teamOpId[42] = Team(
      id: 42,
      name: 'Scanclub',
      ownerId: 9,
      members: const [User(id: 9, name: 'Beheerder')],
    );

    final uitkomst = await controller.verwerkCode('teamplanner:team:42');

    expect(uitkomst, isA<QrScanToegevoegd>());
    expect((uitkomst as QrScanToegevoegd).team.name, 'Scanclub');
    expect(teams.toegevoegde, [(teamId: 42, userId: 1)]);
  });

  test('meldt het wanneer de gebruiker al lid is, zonder addUser', () async {
    teams.teamOpId[42] = const Team(
      id: 42,
      name: 'Scanclub',
      ownerId: 1,
      members: [User(id: 1, name: 'Pedro')],
    );

    final uitkomst = await controller.verwerkCode('teamplanner:team:42');

    expect(uitkomst, isA<QrScanAlLid>());
    expect(teams.toegevoegde, isEmpty);
  });

  test('tweede code tijdens verwerking is geen ongeldige code', () async {
    teams.wachtOpHaalTeam = Completer<void>();
    teams.teamOpId[42] = const Team(
      id: 42,
      name: 'Scanclub',
      ownerId: 9,
      members: [User(id: 9, name: 'Beheerder')],
    );

    final eerste = controller.verwerkCode('teamplanner:team:42');
    await Future<void>.delayed(Duration.zero);
    expect(controller.bezig, isTrue);

    final tweede = await controller.verwerkCode('teamplanner:team:99');
    expect(tweede, isA<QrScanBezig>());
    expect(tweede, isNot(isA<QrScanOngeldigeCode>()));

    teams.wachtOpHaalTeam!.complete();
    final eersteUitkomst = await eerste;
    expect(eersteUitkomst, isA<QrScanToegevoegd>());
  });

  test('meldt het wanneer het team niet bestaat', () async {
    teams.ontbreekt = true;

    final uitkomst = await controller.verwerkCode('teamplanner:team:99');

    expect(uitkomst, isA<QrScanNietGevonden>());
    expect(
      (uitkomst as QrScanNietGevonden).melding,
      const NietGevondenException().bericht,
    );
    expect(teams.toegevoegde, isEmpty);
  });
}

class NepTeamRepository implements TeamRepository {
  final Map<int, Team> teamOpId = {};
  final List<({int teamId, int userId})> toegevoegde = [];
  final List<int> opgehaaldeIds = [];
  bool ontbreekt = false;
  Completer<void>? wachtOpHaalTeam;

  @override
  Future<Team> haalTeam(int id) async {
    opgehaaldeIds.add(id);
    final wacht = wachtOpHaalTeam;
    if (wacht != null) await wacht.future;
    if (ontbreekt) throw const NietGevondenException();
    return teamOpId[id] ?? (throw const NietGevondenException());
  }

  @override
  Future<void> voegGebruikerToe(int teamId, int userId) async {
    toegevoegde.add((teamId: teamId, userId: userId));
  }

  @override
  Future<List<Team>> haalTeams() async => const [];

  @override
  Future<Team> maakTeam({
    required String naam,
    String beschrijving = '',
    String? iconNaam,
  }) async => throw UnimplementedError();

  @override
  Future<Team> wijzigTeam(
    int id, {
    required String naam,
    required String beschrijving,
  }) async => throw UnimplementedError();

  @override
  Future<void> verwijderTeam(int id) async {}

  @override
  Future<Team> verwijderGebruiker(int teamId, int userId) async =>
      throw UnimplementedError();

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
