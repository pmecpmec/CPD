import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/data/repositories/team_repository.dart';
import 'package:crossplatformdevelopment/features/teams/team_detail_controller.dart';
import 'package:crossplatformdevelopment/features/teams/team_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Twee leden zoals de API ze levert: alleen `id` en `name`, zonder rolveld.
/// Wie beheerder is blijkt uitsluitend uit `Team.ownerId` — zie de meting van
/// 12 augustus 2026 in `docs/api-waargenomen-gedrag.md`.
const _beheerder = User(id: 94, name: 'Pedro');
const _lid = User(id: 95, name: 'Sam');

Team _bouwTeam({
  int? ownerId = 94,
  List<User> leden = const [_beheerder, _lid],
}) => Team(
  id: 307,
  name: 'Ledentest',
  description: 'Team voor de widgettest',
  ownerId: ownerId,
  members: leden,
);

/// Testdubbel voor de teamlaag: geen netwerk, en het onthoudt wat er is
/// aangeroepen zodat de test dat kan controleren (NFR-06).
class NepTeamRepository implements TeamRepository {
  NepTeamRepository({Team? team, this.fout}) : _huidig = team ?? _bouwTeam();

  Team _huidig;
  final AppException? fout;

  int? verwijderdLid;
  bool verlaten = false;
  bool verwijderd = false;

  @override
  Future<Team> haalTeam(int id) async {
    if (fout != null) throw fout!;
    return _huidig;
  }

  @override
  Future<Team> verwijderGebruiker(int teamId, int userId) async {
    verwijderdLid = userId;
    // De echte API geeft het bijgewerkte team terug; dat bootst dit na.
    _huidig = _bouwTeam(
      ownerId: _huidig.ownerId,
      leden: _huidig.members.where((lid) => lid.id != userId).toList(),
    );
    return _huidig;
  }

  @override
  Future<void> verlaatTeam(int teamId) async => verlaten = true;

  @override
  Future<void> verwijderTeam(int id) async => verwijderd = true;

  @override
  Future<List<Team>> haalTeams() async => [_huidig];

  @override
  Future<Team> maakTeam({
    required String naam,
    String beschrijving = '',
    String? iconNaam,
  }) async => _huidig;

  @override
  Future<Team> wijzigTeam(
    int id, {
    required String naam,
    required String beschrijving,
  }) async => _huidig;

  @override
  Future<void> voegGebruikerToe(int teamId, int userId) async {}
}

class NepAuthRepository implements AuthRepository {
  NepAuthRepository(this.gebruikerId);

  final int? gebruikerId;

  @override
  Future<int?> huidigeGebruikerId() async => gebruikerId;

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
  /// Bouwt de app met het overzicht eronder en het detailscherm erbovenop,
  /// zodat een test kan zien dat het scherm na een actie echt sluit.
  Widget bouwScherm(TeamDetailController controller) =>
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          initialRoute: '/detail',
          routes: {
            '/': (_) => const Scaffold(body: Center(child: Text('overzicht'))),
            '/detail': (_) => const TeamDetailScreen(),
          },
        ),
      );

  TeamDetailController bouwController({
    required NepTeamRepository teams,
    required int? gebruikerId,
  }) => TeamDetailController(
    teamRepository: teams,
    authRepository: NepAuthRepository(gebruikerId),
    teamId: 307,
  );

  group('rollen (FR-07, FR-08)', () {
    testWidgets('de beheerder ziet de beheerknoppen en geen "Team verlaten"', (
      tester,
    ) async {
      await tester.pumpWidget(
        bouwScherm(
          bouwController(
            teams: NepTeamRepository(),
            gebruikerId: _beheerder.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(OutlinedButton, 'Team verwijderen'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'QR-uitnodiging'),
        findsOneWidget,
      );
      expect(find.text('Je bent beheerder'), findsOneWidget);
      // Een beheerder kan niet vertrekken; de API weigert dat ook.
      expect(find.text('Team verlaten'), findsNothing);
      // De verwijderknop staat alleen bij het andere lid, niet bij zichzelf.
      expect(find.byIcon(Icons.person_remove_outlined), findsOneWidget);
    });

    testWidgets('een gewoon lid ziet alleen "Team verlaten"', (tester) async {
      await tester.pumpWidget(
        bouwScherm(
          bouwController(teams: NepTeamRepository(), gebruikerId: _lid.id),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(OutlinedButton, 'Team verlaten'),
        findsOneWidget,
      );
      expect(find.text('Team verwijderen'), findsNothing);
      expect(find.text('QR-uitnodiging'), findsNothing);
      expect(find.text('Je bent beheerder'), findsNothing);
      expect(find.byIcon(Icons.person_remove_outlined), findsNothing);
      // Een lid mag de volledige inhoud wél zien.
      expect(find.text('Leden (2)'), findsOneWidget);
      expect(find.text('Sam'), findsOneWidget);
    });

    testWidgets(
      'zonder ownerId in het antwoord krijgt niemand beheerdersrechten',
      (tester) async {
        // Een team dat als bijlage bij een match meekomt mist `ownerId`. Zo'n
        // onvolledig antwoord mag nooit per ongeluk rechten opleveren.
        await tester.pumpWidget(
          bouwScherm(
            bouwController(
              teams: NepTeamRepository(team: _bouwTeam(ownerId: null)),
              gebruikerId: _beheerder.id,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Team verwijderen'), findsNothing);
        expect(
          find.widgetWithText(OutlinedButton, 'Team verlaten'),
          findsOneWidget,
        );
      },
    );
  });

  group('privacy (FR-06)', () {
    testWidgets('een niet-lid ziet alleen naam en omschrijving', (
      tester,
    ) async {
      await tester.pumpWidget(
        bouwScherm(
          bouwController(
            teams: NepTeamRepository(),
            // Gebruiker 999 staat niet in de ledenlijst, terwijl de API die
            // lijst wél meestuurt.
            gebruikerId: 999,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ledentest'), findsWidgets);
      expect(find.text('Team voor de widgettest'), findsOneWidget);
      expect(
        find.textContaining('Je bent geen lid van dit team'),
        findsOneWidget,
      );
      expect(find.text('Pedro'), findsNothing);
      expect(find.text('Sam'), findsNothing);
      expect(find.textContaining('Leden ('), findsNothing);
      expect(find.text('Team verlaten'), findsNothing);
      expect(find.text('Team verwijderen'), findsNothing);
    });

    testWidgets('zonder bekend gebruikers-id blijft de ledenlijst dicht', (
      tester,
    ) async {
      await tester.pumpWidget(
        bouwScherm(
          bouwController(teams: NepTeamRepository(), gebruikerId: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Je bent geen lid van dit team'),
        findsOneWidget,
      );
      expect(find.text('Sam'), findsNothing);
    });
  });

  group('acties (FR-07, FR-08)', () {
    testWidgets(
      'verlaten vraagt eerst om bevestiging en sluit dan het scherm',
      (tester) async {
        final teams = NepTeamRepository();
        await tester.pumpWidget(
          bouwScherm(bouwController(teams: teams, gebruikerId: _lid.id)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(OutlinedButton, 'Team verlaten'));
        await tester.pumpAndSettle();
        expect(find.text('Team verlaten?'), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, 'Annuleren'));
        await tester.pumpAndSettle();
        expect(teams.verlaten, isFalse, reason: 'annuleren doet niets');

        await tester.tap(find.widgetWithText(OutlinedButton, 'Team verlaten'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Verlaten'));
        await tester.pumpAndSettle();

        expect(teams.verlaten, isTrue);
        expect(find.text('overzicht'), findsOneWidget);
      },
    );

    testWidgets('de beheerder verwijdert een lid na bevestiging', (
      tester,
    ) async {
      final teams = NepTeamRepository();
      await tester.pumpWidget(
        bouwScherm(bouwController(teams: teams, gebruikerId: _beheerder.id)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_remove_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Lid verwijderen?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Verwijderen'));
      await tester.pumpAndSettle();

      expect(teams.verwijderdLid, _lid.id);
      expect(find.text('Leden (1)'), findsOneWidget);
      expect(find.text('Sam is uit het team verwijderd.'), findsOneWidget);
    });

    testWidgets('de beheerder verwijdert het team na bevestiging', (
      tester,
    ) async {
      final teams = NepTeamRepository();
      await tester.pumpWidget(
        bouwScherm(bouwController(teams: teams, gebruikerId: _beheerder.id)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Team verwijderen'));
      await tester.pumpAndSettle();
      expect(find.text('Team verwijderen?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Verwijderen'));
      await tester.pumpAndSettle();

      expect(teams.verwijderd, isTrue);
      expect(find.text('overzicht'), findsOneWidget);
    });
  });

  testWidgets('een mislukte ophaalpoging toont de melding uit errors.dart', (
    tester,
  ) async {
    await tester.pumpWidget(
      bouwScherm(
        bouwController(
          teams: NepTeamRepository(fout: const NetwerkException()),
          gebruikerId: _lid.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(const NetwerkException().bericht), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Opnieuw proberen'),
      findsOneWidget,
    );
  });
}
