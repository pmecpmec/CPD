import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/event_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/match_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/schedule/my_schedule_controller.dart';
import 'package:crossplatformdevelopment/features/schedule/rooster.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests voor het filteren van het persoonlijk rooster op team (FR-14).
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
  const gamma = Team(
    id: 30,
    name: 'Team Gamma',
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

  Match matchAlphaBeta() => Match(
    id: 33,
    title: 'Gedeelde match',
    start: DateTime(2026, 8, 21, 10),
    end: DateTime(2026, 8, 21, 12),
    teamId: alpha.id,
    team: alpha,
    invites: const [
      MatchInvite(status: InviteStatus.pending, teamId: 20, team: beta),
    ],
  );

  MyScheduleController controllerMet({
    List<Team> teams = const [alpha, beta, gamma],
    List<Event>? events,
    List<Match>? matches,
  }) => MyScheduleController(
    eventRepository: NepEventRepository(
      events ??
          [
            eventVan(alpha, 'Alpha event'),
            eventVan(beta, 'Beta event'),
            eventVan(gamma, 'Gamma event'),
          ],
    ),
    matchRepository: NepMatchRepository(matches ?? [matchAlphaBeta()]),
    teamRepository: NepTeamRepository(teams),
    authRepository: NepAuthRepository(),
    klok: () => klok,
  );

  List<RoosterItem> itemsVan(MyScheduleController controller) => [
    ...controller.verdeling.toekomst,
    ...controller.verdeling.verleden,
  ];

  test('zonder selectie komen alle items terug', () async {
    final controller = controllerMet();
    await controller.laad();

    expect(controller.filterActief, isFalse);
    expect(itemsVan(controller).map((item) => item.titel), [
      'Alpha event',
      'Beta event',
      'Gamma event',
      'Gedeelde match',
    ]);
  });

  test(
    'met één gekozen team komen alleen de items van dat team terug',
    () async {
      final controller = controllerMet();
      await controller.laad();
      controller.wisselTeam(alpha.id);

      expect(controller.filterActief, isTrue);
      expect(itemsVan(controller).map((item) => item.titel), [
        'Alpha event',
        'Gedeelde match',
      ]);
    },
  );

  test('met twee gekozen teams komen de items van beide terug', () async {
    final controller = controllerMet();
    await controller.laad();
    controller.wisselTeam(alpha.id);
    controller.wisselTeam(beta.id);

    expect(itemsVan(controller).map((item) => item.titel), [
      'Alpha event',
      'Beta event',
      'Gedeelde match',
    ]);
  });

  test(
    'match via twee teams blijft zichtbaar bij één gekozen team, één keer',
    () async {
      final controller = controllerMet(
        events: const [],
        matches: [matchAlphaBeta()],
      );
      await controller.laad();

      expect(itemsVan(controller), hasLength(1));

      controller.wisselTeam(alpha.id);
      expect(itemsVan(controller), hasLength(1));
      expect(itemsVan(controller).single.titel, 'Gedeelde match');
      expect(itemsVan(controller).single.teamIds, [alpha.id, beta.id]);
      expect(itemsVan(controller).single.teamNamen, [
        'Team Alpha',
        'Team Beta',
      ]);

      controller.wisFilter();
      controller.wisselTeam(beta.id);
      expect(itemsVan(controller), hasLength(1));
      expect(itemsVan(controller).single.titel, 'Gedeelde match');
    },
  );

  test(
    'isLeegDoorFilter is waar bij selectie zonder resultaat, onwaar bij lege agenda',
    () async {
      final zonderResultaat = controllerMet(
        teams: const [alpha, beta],
        events: [eventVan(alpha, 'Alpha event')],
        matches: const [],
      );
      await zonderResultaat.laad();
      zonderResultaat.wisselTeam(beta.id);
      expect(zonderResultaat.isLeeg, isFalse);
      expect(zonderResultaat.isLeegDoorFilter, isTrue);

      final legeAgenda = controllerMet(events: const [], matches: const []);
      await legeAgenda.laad();
      expect(legeAgenda.isLeeg, isTrue);
      expect(legeAgenda.isLeegDoorFilter, isFalse);
      expect(legeAgenda.filterActief, isFalse);
    },
  );

  test('wis maakt de teamselectie leeg', () async {
    final controller = controllerMet();
    await controller.laad();
    controller.wisselTeam(alpha.id);
    expect(controller.gekozenTeamIds, {alpha.id});

    controller.wis();

    expect(controller.gekozenTeamIds, isEmpty);
    expect(controller.filterActief, isFalse);
    expect(controller.eigenTeams, isEmpty);
    expect(controller.verdeling.isLeeg, isTrue);
  });

  test(
    'eigenTeams is gesorteerd op naam en laad wist het filter niet',
    () async {
      final controller = controllerMet(teams: const [gamma, alpha, beta]);
      await controller.laad();
      expect(controller.eigenTeams.map((team) => team.name), [
        'Team Alpha',
        'Team Beta',
        'Team Gamma',
      ]);

      controller.wisselTeam(beta.id);
      await controller.laad();
      expect(controller.gekozenTeamIds, {beta.id});
      expect(controller.filterActief, isTrue);
    },
  );

  test(
    'laad haalt team-ids die niet meer in eigenTeams zitten uit de selectie',
    () async {
      final teams = NepTeamRepository([alpha, beta]);
      final controller = MyScheduleController(
        eventRepository: NepEventRepository([eventVan(alpha, 'Alpha event')]),
        matchRepository: NepMatchRepository(const []),
        teamRepository: teams,
        authRepository: NepAuthRepository(),
        klok: () => klok,
      );
      await controller.laad();
      controller.wisselTeam(alpha.id);
      controller.wisselTeam(beta.id);

      teams.teams = [alpha];
      await controller.laad();

      expect(controller.gekozenTeamIds, {alpha.id});
      expect(controller.eigenTeams.map((team) => team.id), [alpha.id]);
    },
  );

  test('vanEvent vult teamIds uit Event.teamId', () {
    final item = RoosterItem.vanEvent(eventVan(alpha, 'Alpha event'));
    expect(item.teamIds, [alpha.id]);
    expect(item.teamNamen, ['Team Alpha']);
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

  List<Team> teams;

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
