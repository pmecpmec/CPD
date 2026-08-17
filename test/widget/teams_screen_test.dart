import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/auth/auth_controller.dart';
import 'package:crossplatformdevelopment/features/teams/teams_controller.dart';
import 'package:crossplatformdevelopment/features/teams/teams_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Testdubbel zonder netwerk. Het overzicht blijft leeg.
class NepTeamRepository implements TeamRepository {
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
  Widget bouwScherm() {
    final auth = NepAuthRepository();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(auth)),
        ChangeNotifierProvider(
          create: (_) => TeamsController(NepTeamRepository(), auth),
        ),
      ],
      child: const MaterialApp(home: TeamsScreen()),
    );
  }

  testWidgets(
    'validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer',
    (tester) async {
      await tester.pumpWidget(bouwScherm());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Nieuw team'));
      await tester.pumpAndSettle();

      expect(find.text('Nieuw team'), findsWidgets);

      await tester.tap(find.widgetWithText(FilledButton, 'Aanmaken'));
      await tester.pump();

      expect(find.text('Vul een teamnaam in.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Herstelteam');
      await tester.pump();

      expect(find.text('Vul een teamnaam in.'), findsNothing);
    },
  );
}
