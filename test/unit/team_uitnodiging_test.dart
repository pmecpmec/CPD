import 'package:crossplatformdevelopment/core/config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests voor de vorm van de QR-uitnodiging (FR-09).
///
/// De code is het enige wat de tonende en de scannende kant delen: er is geen
/// uitnodigings-endpoint in de API. Breekt dit formaat, dan werkt het scannen
/// niet meer, terwijl geen enkel scherm stukloopt. Daarom staat het formaat op
/// één plek en wordt het hier vastgelegd.
void main() {
  group('TeamUitnodiging.bouwCode', () {
    test('heeft de afgesproken vorm en bevat het team-id', () {
      expect(TeamUitnodiging.bouwCode(42), 'teamplanner:team:42');
      expect(TeamUitnodiging.bouwCode(306), 'teamplanner:team:306');
    });

    test('begint met het voorvoegsel en eindigt op het team-id', () {
      const teamId = 307;
      final code = TeamUitnodiging.bouwCode(teamId);

      expect(code, startsWith(TeamUitnodiging.voorvoegsel));
      expect(code.split(':'), ['teamplanner', 'team', '$teamId']);
      expect(code, contains('$teamId'));
    });

    test('geeft elk team een eigen code', () {
      expect(
        TeamUitnodiging.bouwCode(305),
        isNot(TeamUitnodiging.bouwCode(306)),
      );
    });

    test('een gebouwde code is weer terug te lezen', () {
      // Tonen (FR-09) en scannen (FR-10) gebruiken dezelfde twee functies; deze
      // heen-en-terugweg is de reden dat ze bij elkaar staan.
      expect(TeamUitnodiging.leesTeamId(TeamUitnodiging.bouwCode(306)), 306);
    });
  });

  group('TeamUitnodiging.leesTeamId', () {
    test('leest een geldige code', () {
      expect(TeamUitnodiging.leesTeamId('teamplanner:team:42'), 42);
      expect(TeamUitnodiging.leesTeamId('  teamplanner:team:42  '), 42);
    });

    test('wijst drie ongeldige codes af', () {
      expect(TeamUitnodiging.leesTeamId('https://voorbeeld.nl'), isNull);
      expect(TeamUitnodiging.leesTeamId('teamplanner:team:'), isNull);
      expect(TeamUitnodiging.leesTeamId('teamplanner:team:42:extra'), isNull);
    });

    test('wijst nul, negatief en ontbrekend af', () {
      expect(TeamUitnodiging.leesTeamId('teamplanner:team:0'), isNull);
      expect(TeamUitnodiging.leesTeamId(null), isNull);
      expect(TeamUitnodiging.leesTeamId(''), isNull);
    });
  });
}
