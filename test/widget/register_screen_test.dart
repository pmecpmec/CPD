import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/features/auth/auth_controller.dart';
import 'package:crossplatformdevelopment/features/auth/login_screen.dart';
import 'package:crossplatformdevelopment/features/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Testdubbel voor de authenticatielaag: geen netwerk.
class NepAuthRepository implements AuthRepository {
  NepAuthRepository({this.laatRegistrerenMislukken = false});

  final bool laatRegistrerenMislukken;

  @override
  Future<void> login({
    required String naam,
    required String wachtwoord,
  }) async {}

  @override
  Future<void> registreer({
    required String naam,
    required String wachtwoord,
  }) async {
    if (laatRegistrerenMislukken) {
      throw const ValidatieException('Deze gebruikersnaam is al in gebruik.');
    }
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> heeftSessie() async => false;

  @override
  Future<int?> huidigeGebruikerId() async => 1;
}

void main() {
  Widget bouwScherm() => ChangeNotifierProvider(
    create: (_) => AuthController(NepAuthRepository()),
    child: const MaterialApp(home: RegisterScreen()),
  );

  Widget bouwMetLogin(AuthController controller) =>
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {RegisterScreen.routeNaam: (_) => const RegisterScreen()},
        ),
      );

  Future<void> vulEnVerstuur(WidgetTester tester) async {
    final velden = find.descendant(
      of: find.byType(RegisterScreen),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(velden.at(0), 'pedro');
    await tester.enterText(velden.at(1), 'geheim123');
    await tester.enterText(velden.at(2), 'geheim123');
    await tester.tap(find.widgetWithText(FilledButton, 'Account aanmaken'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd',
    (tester) async {
      await tester.pumpWidget(bouwScherm());

      await tester.tap(find.widgetWithText(FilledButton, 'Account aanmaken'));
      await tester.pump();

      expect(find.text('Vul een gebruikersnaam in.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'pedro');
      await tester.pump();

      expect(find.text('Vul een gebruikersnaam in.'), findsNothing);
    },
  );

  testWidgets(
    'AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan',
    (tester) async {
      final controller = AuthController(
        NepAuthRepository(laatRegistrerenMislukken: true),
      );
      await tester.pumpWidget(bouwMetLogin(controller));

      await tester.tap(find.text('Nog geen account? Registreren'));
      await tester.pumpAndSettle();

      await vulEnVerstuur(tester);
      expect(
        find.text('Deze gebruikersnaam is al in gebruik.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(controller.foutmelding, isNull);
      expect(find.text('Deze gebruikersnaam is al in gebruik.'), findsNothing);
    },
  );

  testWidgets(
    'systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan',
    (tester) async {
      final controller = AuthController(
        NepAuthRepository(laatRegistrerenMislukken: true),
      );
      await tester.pumpWidget(bouwMetLogin(controller));

      await tester.tap(find.text('Nog geen account? Registreren'));
      await tester.pumpAndSettle();

      await vulEnVerstuur(tester);
      expect(
        find.text('Deze gebruikersnaam is al in gebruik.'),
        findsOneWidget,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(controller.foutmelding, isNull);
      expect(find.text('Deze gebruikersnaam is al in gebruik.'), findsNothing);
    },
  );
}
