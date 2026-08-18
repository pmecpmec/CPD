import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/event_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/match_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/auth/auth_controller.dart';
import 'package:crossplatformdevelopment/features/schedule/my_schedule_controller.dart';
import 'package:crossplatformdevelopment/features/teams/home_shell.dart';
import 'package:crossplatformdevelopment/features/teams/teams_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _NepAuthRepository implements AuthRepository {
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

class _NepTeamRepository implements TeamRepository {
  @override
  Future<List<Team>> haalTeams() async => const [];

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

class _NepEventRepository implements EventRepository {
  @override
  Future<List<Event>> haalEvents() async => const [];

  @override
  Future<Event> haalEvent(int id) async => throw UnimplementedError();

  @override
  Future<Event> maakEvent({
    required int teamId,
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving = '',
    GeoLocatie? locatie,
    String? locatieNaam,
  }) async => throw UnimplementedError();

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
  }) async => throw UnimplementedError();

  @override
  Future<void> verwijderEvent(int id) async {}
}

class _NepMatchRepository implements MatchRepository {
  @override
  Future<List<Match>> haalMatches() async => const [];

  @override
  Future<Match> haalMatch(int id) async => throw UnimplementedError();
}

/// Telt hoe vaak [laad] wordt aangeroepen, zonder de server te raken.
class _TelScheduleController extends MyScheduleController {
  _TelScheduleController()
    : super(
        eventRepository: _NepEventRepository(),
        matchRepository: _NepMatchRepository(),
        teamRepository: _NepTeamRepository(),
        authRepository: _NepAuthRepository(),
      );

  int aantalLaad = 0;

  @override
  Future<void> laad() async {
    aantalLaad++;
  }
}

void main() {
  Widget bouw({required _TelScheduleController agenda, required Size formaat}) {
    final auth = _NepAuthRepository();
    return MediaQuery(
      data: MediaQueryData(size: formaat),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController(auth)),
          ChangeNotifierProvider(
            create: (_) => TeamsController(_NepTeamRepository(), auth),
          ),
          ChangeNotifierProvider<MyScheduleController>.value(value: agenda),
        ],
        child: const MaterialApp(home: HomeShell()),
      ),
    );
  }

  Future<void> tikAgendaEnBewijsLaad(
    WidgetTester tester, {
    required Size formaat,
  }) async {
    final agenda = _TelScheduleController();
    await tester.pumpWidget(bouw(agenda: agenda, formaat: formaat));
    await tester.pump();

    final voor = agenda.aantalLaad;
    expect(voor, greaterThan(0), reason: 'initState laadt de agenda een keer');

    await tester.tap(find.text('Agenda').first);
    await tester.pump();

    expect(
      agenda.aantalLaad,
      voor + 1,
      reason: 'opnieuw laden bij openen van het tabblad Agenda',
    );
  }

  testWidgets(
    'NavigationBar laadt de agenda opnieuw bij openen van het tabblad',
    (tester) async {
      await tikAgendaEnBewijsLaad(tester, formaat: const Size(390, 800));
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets(
    'NavigationRail laadt de agenda opnieuw bij openen van het tabblad',
    (tester) async {
      await tikAgendaEnBewijsLaad(tester, formaat: const Size(900, 800));
      expect(find.byType(NavigationRail), findsOneWidget);
    },
  );
}
