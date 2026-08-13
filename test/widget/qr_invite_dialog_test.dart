import 'package:crossplatformdevelopment/core/config.dart';
import 'package:crossplatformdevelopment/features/teams/qr_invite_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Widgettest voor de getoonde uitnodiging (FR-09).
///
/// Of een echte telefoon de code van het scherm leest, valt hier niet te
/// controleren; wat wél te controleren is, is dat de code van dit team in beeld
/// staat, groot genoeg is en een witte rand heeft.
void main() {
  const team = (id: 306, naam: 'Testteam A');

  Widget bouwScherm() => MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => QrInviteDialog.toon(
            context,
            teamId: team.id,
            teamNaam: team.naam,
          ),
          child: const Text('Openen'),
        ),
      ),
    ),
  );

  testWidgets('toont de code van dit team met de teamnaam erbij', (
    tester,
  ) async {
    await tester.pumpWidget(bouwScherm());
    await tester.tap(find.text('Openen'));
    await tester.pumpAndSettle();

    // `QrImageView` houdt de data privé, dus de code staat ook als tekst onder
    // de afbeelding: leesbaar voor de gebruiker en controleerbaar in een test.
    expect(find.text(TeamUitnodiging.bouwCode(team.id)), findsOneWidget);
    expect(find.text('teamplanner:team:306'), findsOneWidget);

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.semanticsLabel, contains(team.naam));
    expect(find.textContaining(team.naam), findsOneWidget);
  });

  testWidgets('is minimaal 240 pixels groot en heeft een witte rand', (
    tester,
  ) async {
    await tester.pumpWidget(bouwScherm());
    await tester.tap(find.text('Openen'));
    await tester.pumpAndSettle();

    final code = tester.getSize(find.byType(QrImageView));
    expect(code.width, greaterThanOrEqualTo(240));
    expect(code.height, greaterThanOrEqualTo(240));

    // De rand eromheen is wit, ongeacht het thema: zonder die stille zone
    // herkent een scanner de code op een donkere achtergrond niet.
    final omlijsting = tester.widget<Container>(
      find
          .ancestor(
            of: find.byType(QrImageView),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(omlijsting.padding, const EdgeInsets.all(QrInviteDialog.marge));
    expect((omlijsting.decoration as BoxDecoration).color, Colors.white);
  });
}
