import 'package:crossplatformdevelopment/core/theme.dart';
import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/event_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/match_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/schedule/my_schedule_controller.dart';
import 'package:crossplatformdevelopment/features/schedule/my_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Widgettests voor de filterchips op het persoonlijk rooster (FR-14).
void main() {
  const gebruiker = User(id: 1, name: 'Pedro');
  final klok = DateTime(2026, 8, 17, 12);

  const alpha = Team(
    id: 10,
    name: 'Team Alpha',
    ownerId: 1,
    members: [gebruiker],
  );
  const beta = Team(
    id: 20,
    name: 'Team Beta',
    ownerId: 1,
    members: [gebruiker],
  );

  Event eventVan(Team team, String titel) => Event(
    id: team.id,
    title: titel,
    start: DateTime(2026, 8, 20, 10),
    end: DateTime(2026, 8, 20, 12),
    teamId: team.id,
    team: team,
  );

  Widget bouwScherm({required List<Team> teams, required List<Event> events}) {
    final controller = MyScheduleController(
      eventRepository: NepEventRepository(events),
      matchRepository: NepMatchRepository(const []),
      teamRepository: NepTeamRepository(teams),
      authRepository: NepAuthRepository(),
      klok: () => klok,
    );
    return ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        theme: AppTheme.licht(),
        home: const MyScheduleScreen(),
      ),
    );
  }

  Future<void> laadScherm(WidgetTester tester, Widget scherm) async {
    await tester.pumpWidget(scherm);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('toont geen filterchips bij één team', (tester) async {
    await laadScherm(
      tester,
      bouwScherm(
        teams: const [alpha],
        events: [eventVan(alpha, 'Alpha event')],
      ),
    );

    expect(find.text('Alpha event'), findsOneWidget);
    expect(find.byType(FilterChip), findsNothing);
    expect(find.text('Alles tonen'), findsNothing);
  });

  testWidgets('toont filterchips bij twee teams', (tester) async {
    await laadScherm(
      tester,
      bouwScherm(
        teams: const [alpha, beta],
        events: [eventVan(alpha, 'Alpha event'), eventVan(beta, 'Beta event')],
      ),
    );

    expect(find.byType(FilterChip), findsNWidgets(2));
    expect(find.widgetWithText(FilterChip, 'Team Alpha'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Team Beta'), findsOneWidget);
    expect(find.text('Alpha event'), findsOneWidget);
    expect(find.text('Beta event'), findsOneWidget);
  });

  testWidgets('een chip aantikken maakt de lijst korter', (tester) async {
    await laadScherm(
      tester,
      bouwScherm(
        teams: const [alpha, beta],
        events: [eventVan(alpha, 'Alpha event'), eventVan(beta, 'Beta event')],
      ),
    );

    expect(find.text('Alpha event'), findsOneWidget);
    expect(find.text('Beta event'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Team Alpha'));
    await tester.pump();

    expect(find.text('Alpha event'), findsOneWidget);
    expect(find.text('Beta event'), findsNothing);
    expect(find.text('Alles tonen'), findsWidgets);
  });
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

class NepTeamRepository implements TeamRepository {
  NepTeamRepository(this.teams);

  final List<Team> teams;

  @override
  Future<List<Team>> haalTeams() async => teams;

  @override
  Future<Team> haalTeam(int id) => throw UnimplementedError();

  @override
  Future<Team> maakTeam({
    required String naam,
    String beschrijving = '',
    String? iconNaam,
  }) => throw UnimplementedError();

  @override
  Future<Team> wijzigTeam(
    int id, {
    required String naam,
    required String beschrijving,
  }) => throw UnimplementedError();

  @override
  Future<void> verwijderTeam(int id) async {}

  @override
  Future<void> voegGebruikerToe(int teamId, int userId) async {}

  @override
  Future<Team> verwijderGebruiker(int teamId, int userId) =>
      throw UnimplementedError();

  @override
  Future<void> verlaatTeam(int teamId) async {}
}

class NepEventRepository implements EventRepository {
  NepEventRepository(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> haalEvents() async => events;

  @override
  Future<Event> haalEvent(int id) => throw UnimplementedError();

  @override
  Future<Event> maakEvent({
    required int teamId,
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving = '',
    GeoLocatie? locatie,
    String? locatieNaam,
  }) => throw UnimplementedError();

  @override
  Future<Event> wijzigEvent(
    int id, {
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving = '',
    GeoLocatie? locatie,
    String? locatieNaam,
    int? teamId,
  }) => throw UnimplementedError();

  @override
  Future<void> verwijderEvent(int id) async {}
}

class NepMatchRepository implements MatchRepository {
  NepMatchRepository(this.matches);

  final List<Match> matches;

  @override
  Future<List<Match>> haalMatches() async => matches;

  @override
  Future<Match> haalMatch(int id) => throw UnimplementedError();

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
  }) => throw UnimplementedError();

  @override
  Future<List<MatchInvite>> haalOntvangenUitnodigingen() async => const [];

  @override
  Future<MatchInvite> beantwoordUitnodiging(
    int inviteId,
    InviteStatus status,
  ) => throw UnimplementedError();
}
