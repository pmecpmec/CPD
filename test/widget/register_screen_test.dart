import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/features/auth/auth_controller.dart';
import 'package:crossplatformdevelopment/features/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Testdubbel voor de authenticatielaag: geen netwerk.
class NepAuthRepository implements AuthRepository {
  @override
  Future<void> login({
    required String naam,
    required String wachtwoord,
  }) async {}

  @override
  Future<void> registreer({
    required String naam,
    required String wachtwoord,
  }) async {}

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
}
