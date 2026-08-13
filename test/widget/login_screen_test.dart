import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:crossplatformdevelopment/data/repositories/auth_repository.dart';
import 'package:crossplatformdevelopment/features/auth/auth_controller.dart';
import 'package:crossplatformdevelopment/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Testdubbel voor de authenticatielaag: geen netwerk, volledig voorspelbaar.
class NepAuthRepository implements AuthRepository {
  NepAuthRepository({this.laatLoginMislukken = false});

  final bool laatLoginMislukken;
  String? gebruikteNaam;
  String? gebruiktWachtwoord;
  int aantalLoginPogingen = 0;

  @override
  Future<void> login({required String naam, required String wachtwoord}) async {
    aantalLoginPogingen++;
    gebruikteNaam = naam;
    gebruiktWachtwoord = wachtwoord;
    if (laatLoginMislukken) throw const OngeldigeInlogException();
  }

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
  Widget bouwScherm(AuthController controller) => ChangeNotifierProvider.value(
    value: controller,
    child: const MaterialApp(home: LoginScreen()),
  );

  testWidgets('toont de invoervelden en de inlogknop', (tester) async {
    await tester.pumpWidget(bouwScherm(AuthController(NepAuthRepository())));

    expect(find.text('Gebruikersnaam'), findsOneWidget);
    expect(find.text('Wachtwoord'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Inloggen'), findsOneWidget);
  });

  testWidgets('waarschuwt bij lege velden en roept de server niet aan', (
    tester,
  ) async {
    final repo = NepAuthRepository();
    await tester.pumpWidget(bouwScherm(AuthController(repo)));

    await tester.tap(find.widgetWithText(FilledButton, 'Inloggen'));
    await tester.pump();

    expect(find.text('Vul een gebruikersnaam in.'), findsOneWidget);
    expect(find.text('Vul een wachtwoord in.'), findsOneWidget);
    expect(repo.aantalLoginPogingen, 0);
  });

  testWidgets('stuurt de ingevulde gegevens door bij een geldige invoer', (
    tester,
  ) async {
    final repo = NepAuthRepository();
    final controller = AuthController(repo);
    await tester.pumpWidget(bouwScherm(controller));

    await tester.enterText(find.byType(TextFormField).first, 'pedro');
    await tester.enterText(find.byType(TextFormField).last, 'geheim123');
    await tester.tap(find.widgetWithText(FilledButton, 'Inloggen'));
    await tester.pumpAndSettle();

    expect(repo.gebruikteNaam, 'pedro');
    expect(repo.gebruiktWachtwoord, 'geheim123');
    expect(controller.isIngelogd, isTrue);
  });

  testWidgets('toont een melding wanneer het inloggen mislukt', (tester) async {
    final repo = NepAuthRepository(laatLoginMislukken: true);
    final controller = AuthController(repo);
    await tester.pumpWidget(bouwScherm(controller));

    await tester.enterText(find.byType(TextFormField).first, 'pedro');
    await tester.enterText(find.byType(TextFormField).last, 'fout');
    await tester.tap(find.widgetWithText(FilledButton, 'Inloggen'));
    await tester.pumpAndSettle();

    expect(
      find.text('Gebruikersnaam of wachtwoord klopt niet.'),
      findsOneWidget,
    );
    expect(controller.isIngelogd, isFalse);
  });
}
