import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/features/schedule/rooster.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests voor het ontdubbelen in het persoonlijk rooster (FR-14).
void main() {
  final start = DateTime(2026, 8, 18, 10);
  final eind = DateTime(2026, 8, 18, 12);

  RoosterItem matchViaTeam({
    required int matchId,
    required String titel,
    required String teamNaam,
    int? teamId,
  }) => RoosterItem(
    soort: RoosterSoort.match,
    id: matchId,
    titel: titel,
    start: start,
    eind: eind,
    teamNamen: [teamNaam],
    teamIds: [?teamId],
    statusLabel: InviteStatus.pending.label,
  );

  test('dezelfde match via twee teams wordt één item met beide namen', () {
    final viaA = matchViaTeam(
      matchId: 33,
      titel: 'Testmatch',
      teamNaam: 'Testteam A',
      teamId: 10,
    );
    final viaB = matchViaTeam(
      matchId: 33,
      titel: 'Testmatch',
      teamNaam: 'Testteam B',
      teamId: 20,
    );

    final resultaat = ontdubbelRoosterItems([viaA, viaB]);

    expect(resultaat, hasLength(1));
    expect(resultaat.single.id, 33);
    expect(resultaat.single.soort, RoosterSoort.match);
    expect(resultaat.single.teamNamen, ['Testteam A', 'Testteam B']);
    expect(resultaat.single.teamIds, [10, 20]);
  });

  test('twee verschillende matches blijven twee items', () {
    final een = matchViaTeam(matchId: 33, titel: 'Eerste', teamNaam: 'Team A');
    final twee = matchViaTeam(matchId: 34, titel: 'Tweede', teamNaam: 'Team B');

    final resultaat = ontdubbelRoosterItems([een, twee]);

    expect(resultaat, hasLength(2));
    expect(resultaat.map((item) => item.id), [33, 34]);
  });

  test('events worden niet samengevoegd, ook niet bij hetzelfde id', () {
    // Event 10 en match 10 zijn verschillende dingen; ontdubbelen gaat alleen
    // over matches.
    final event = RoosterItem(
      soort: RoosterSoort.event,
      id: 10,
      titel: 'Training',
      start: start,
      eind: eind,
      teamNamen: ['Team A'],
    );
    final match = matchViaTeam(
      matchId: 10,
      titel: 'Testmatch',
      teamNaam: 'Team A',
    );

    final resultaat = ontdubbelRoosterItems([event, match]);

    expect(resultaat, hasLength(2));
    expect(resultaat.first.soort, RoosterSoort.event);
    expect(resultaat.last.soort, RoosterSoort.match);
  });
}
