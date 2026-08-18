import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/auth/auth_controller.dart';
import 'package:crossplatformdevelopment/features/teams/qr_scan_controller.dart';
import 'package:crossplatformdevelopment/features/teams/qr_scan_screen.dart';
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
  Widget bouwTeamsScherm() {
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

  testWidgets('toont een scan-knop naast Nieuw team', (tester) async {
    await tester.pumpWidget(bouwTeamsScherm());
    await tester.pumpAndSettle();

    expect(find.byTooltip('QR-code scannen'), findsOneWidget);
    expect(
      find.widgetWithText(FloatingActionButton, 'Nieuw team'),
      findsOneWidget,
    );
  });

  testWidgets('geweigerde camera toont uitleg en een knop Instellingen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => QrScanController(
          teamRepository: NepTeamRepository(),
          authRepository: NepAuthRepository(),
        ),
        child: const MaterialApp(home: QrScanScreen(cameraGeweigerd: true)),
      ),
    );

    expect(find.text('Camera niet beschikbaar'), findsOneWidget);
    expect(find.textContaining('toegang tot de camera nodig'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Instellingen'), findsOneWidget);
  });
}
