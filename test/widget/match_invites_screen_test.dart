import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/match_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/matches/match_invites_controller.dart';
import 'package:crossplatformdevelopment/features/matches/match_invites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  MatchInvite invite({
    required int id,
    required InviteStatus status,
    int matchId = 33,
  }) => MatchInvite(id: id, matchId: matchId, status: status);

  Match match({required InviteStatus status}) => Match(
    id: 33,
    title: 'Testmatch',
    start: DateTime(2026, 8, 14, 15),
    end: DateTime(2026, 8, 14, 17),
    teamId: 306,
    invites: [MatchInvite(teamId: 305, status: status)],
  );

  Future<void> open(
    WidgetTester tester, {
    required List<MatchInvite> invites,
  }) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final status = invites.isEmpty
        ? InviteStatus.pending
        : invites.first.status;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MatchInvitesController(
          matchRepository: NepMatchRepository(
            invites: invites,
            matches: [match(status: status)],
          ),
          teamRepository: NepTeamRepository(),
          authRepository: NepAuthRepository(),
        ),
        child: const MaterialApp(home: MatchInvitesScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('biedt bij pending accepteren en afwijzen', (tester) async {
    await open(tester, invites: [invite(id: 32, status: InviteStatus.pending)]);

    expect(find.text('Testmatch'), findsOneWidget);
    expect(find.text('Accepteren'), findsOneWidget);
    expect(find.text('Afwijzen'), findsOneWidget);
    expect(find.text('Annuleren'), findsNothing);
  });

  testWidgets('biedt bij accepted alleen annuleren', (tester) async {
    await open(
      tester,
      invites: [invite(id: 32, status: InviteStatus.accepted)],
    );

    expect(find.text('Accepteren'), findsNothing);
    expect(find.text('Afwijzen'), findsNothing);
    expect(find.text('Annuleren'), findsOneWidget);
  });

  testWidgets('biedt bij declined geen overgang', (tester) async {
    await open(
      tester,
      invites: [invite(id: 32, status: InviteStatus.declined)],
    );

    expect(find.text('Afgewezen'), findsOneWidget);
    expect(find.text('Accepteren'), findsNothing);
    expect(find.text('Afwijzen'), findsNothing);
    expect(find.text('Annuleren'), findsNothing);
  });
}

class NepMatchRepository implements MatchRepository {
  NepMatchRepository({this.invites = const [], this.matches = const []});

  final List<MatchInvite> invites;
  final List<Match> matches;

  @override
  Future<List<MatchInvite>> haalOntvangenUitnodigingen() async => invites;

  @override
  Future<List<Match>> haalMatches() async => matches;

  @override
  Future<Match> haalMatch(int id) async =>
      matches.firstWhere((match) => match.id == id);

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
  }) async => throw UnimplementedError();

  @override
  Future<MatchInvite> beantwoordUitnodiging(
    int inviteId,
    InviteStatus status,
  ) async => throw UnimplementedError();
}

class NepTeamRepository implements TeamRepository {
  @override
  Future<List<Team>> haalTeams() async => const [
    Team(id: 305, name: 'Team B', ownerId: 1),
  ];

  @override
  Future<Team> haalTeam(int id) async => throw UnimplementedError();

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
  Future<void> voegGebruikerToe(int teamId, int userId) async {}

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
