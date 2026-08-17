import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/features/schedule/rooster.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests voor het sorteren en scheiden van het rooster (FR-13).
///
/// "Nu" is altijd hetzelfde moment, zodat de scheiding tussen verleden en
/// toekomst niet van de klok van de machine afhangt.
void main() {
  final nu = DateTime(2026, 8, 17, 12, 0);

  RoosterItem event({
    required int id,
    required String titel,
    required DateTime start,
    required DateTime eind,
    String teamNaam = 'Team A',
  }) => RoosterItem(
    soort: RoosterSoort.event,
    id: id,
    titel: titel,
    start: start,
    eind: eind,
    teamNamen: [teamNaam],
  );

  Match match({
    required int id,
    required String titel,
    required DateTime start,
    required DateTime eind,
    int teamId = 306,
    List<MatchInvite> invites = const [],
    Team? team,
  }) => Match(
    id: id,
    title: titel,
    start: start,
    end: eind,
    teamId: teamId,
    team: team,
    invites: invites,
  );

  group('verdeelRooster', () {
    test('zet een leeg rooster in twee lege delen', () {
      final verdeling = verdeelRooster(const [], nu: nu);

      expect(verdeling.isLeeg, isTrue);
      expect(verdeling.toekomst, isEmpty);
      expect(verdeling.verleden, isEmpty);
    });

    test('zet afgelopen items in het verleden en de rest in de toekomst', () {
      final geweest = event(
        id: 1,
        titel: 'Training',
        start: DateTime(2026, 8, 16, 10),
        eind: DateTime(2026, 8, 16, 12),
      );
      final bezig = event(
        id: 2,
        titel: 'Overleg',
        start: DateTime(2026, 8, 17, 11),
        eind: DateTime(2026, 8, 17, 13),
      );
      final later = event(
        id: 3,
        titel: 'Toernooi',
        start: DateTime(2026, 8, 18, 10),
        eind: DateTime(2026, 8, 18, 12),
      );

      final verdeling = verdeelRooster([later, geweest, bezig], nu: nu);

      expect(verdeling.verleden.map((item) => item.id), [1]);
      expect(verdeling.toekomst.map((item) => item.id), [2, 3]);
    });

    test('sorteert de toekomst op begintijd, vroegste eerst', () {
      final later = event(
        id: 1,
        titel: 'Later',
        start: DateTime(2026, 8, 19, 10),
        eind: DateTime(2026, 8, 19, 12),
      );
      final eerder = event(
        id: 2,
        titel: 'Eerder',
        start: DateTime(2026, 8, 18, 10),
        eind: DateTime(2026, 8, 18, 12),
      );

      final verdeling = verdeelRooster([later, eerder], nu: nu);

      expect(verdeling.toekomst.map((item) => item.titel), ['Eerder', 'Later']);
    });

    test('sorteert het verleden op begintijd, meest recent eerst', () {
      final oud = event(
        id: 1,
        titel: 'Oud',
        start: DateTime(2026, 8, 10, 10),
        eind: DateTime(2026, 8, 10, 12),
      );
      final recent = event(
        id: 2,
        titel: 'Recent',
        start: DateTime(2026, 8, 16, 10),
        eind: DateTime(2026, 8, 16, 12),
      );

      final verdeling = verdeelRooster([oud, recent], nu: nu);

      expect(verdeling.verleden.map((item) => item.titel), ['Recent', 'Oud']);
    });

    test('sorteert bij gelijke begintijd op titel', () {
      final b = event(
        id: 1,
        titel: 'Brainstorm',
        start: DateTime(2026, 8, 18, 10),
        eind: DateTime(2026, 8, 18, 11),
      );
      final a = event(
        id: 2,
        titel: 'Afsluiting',
        start: DateTime(2026, 8, 18, 10),
        eind: DateTime(2026, 8, 18, 11),
      );

      final verdeling = verdeelRooster([b, a], nu: nu);

      expect(verdeling.toekomst.map((item) => item.titel), [
        'Afsluiting',
        'Brainstorm',
      ]);
    });

    test('zet een item dat precies nu eindigt bij de toekomst', () {
      final opDeGrens = event(
        id: 1,
        titel: 'Net klaar',
        start: DateTime(2026, 8, 17, 10),
        eind: nu,
      );

      final verdeling = verdeelRooster([opDeGrens], nu: nu);

      expect(verdeling.toekomst, hasLength(1));
      expect(verdeling.verleden, isEmpty);
    });
  });

  group('matchStatusLabel', () {
    final start = DateTime(2026, 8, 18, 10);
    final eind = DateTime(2026, 8, 18, 12);

    test('vertaalt pending, accepted en declined naar Nederlandse labels', () {
      Match met(InviteStatus status) => match(
        id: 33,
        titel: 'Testmatch',
        start: start,
        eind: eind,
        invites: [MatchInvite(status: status, teamId: 305)],
      );

      expect(
        matchStatusLabel(met(InviteStatus.pending), {305}),
        'In afwachting',
      );
      expect(
        matchStatusLabel(met(InviteStatus.accepted), {305}),
        'Geaccepteerd',
      );
      expect(matchStatusLabel(met(InviteStatus.declined), {305}), 'Afgewezen');
    });

    test('toont voor de organisator of iedereen heeft geaccepteerd', () {
      final pending = match(
        id: 33,
        titel: 'Testmatch',
        start: start,
        eind: eind,
        teamId: 306,
        invites: const [MatchInvite(status: InviteStatus.pending, teamId: 305)],
      );
      final akkoord = match(
        id: 33,
        titel: 'Testmatch',
        start: start,
        eind: eind,
        teamId: 306,
        invites: const [
          MatchInvite(status: InviteStatus.accepted, teamId: 305),
        ],
      );
      final afgewezen = match(
        id: 33,
        titel: 'Testmatch',
        start: start,
        eind: eind,
        teamId: 306,
        invites: const [
          MatchInvite(status: InviteStatus.declined, teamId: 305),
        ],
      );

      expect(matchStatusLabel(pending, {306}), 'In afwachting');
      expect(matchStatusLabel(akkoord, {306}), 'Geaccepteerd');
      expect(matchStatusLabel(afgewezen, {306}), 'Afgewezen');
    });
  });

  group('RoosterItem.vanEvent en vanMatch', () {
    test('neemt de teamnaam uit het ingebedde team van het event', () {
      final item = RoosterItem.vanEvent(
        Event(
          id: 88,
          title: 'Testafspraak',
          start: DateTime(2026, 8, 13, 15, 1, 58),
          end: DateTime(2026, 8, 13, 17, 1, 58),
          teamId: 306,
          team: const Team(id: 306, name: 'Testteam A'),
        ),
      );

      expect(item.soort, RoosterSoort.event);
      expect(item.titel, 'Testafspraak');
      expect(item.teamNamen, ['Testteam A']);
      expect(item.statusLabel, isNull);
      expect(item.event?.id, 88);
    });

    test('zet bij een match de status en de betrokken teamnamen', () {
      final item = RoosterItem.vanMatch(
        match(
          id: 33,
          titel: 'Testmatch',
          start: DateTime(2026, 8, 14, 15, 1, 58),
          eind: DateTime(2026, 8, 14, 17, 1, 58),
          teamId: 306,
          team: const Team(id: 306, name: 'Testteam A'),
          invites: const [
            MatchInvite(
              status: InviteStatus.pending,
              teamId: 305,
              team: Team(id: 305, name: 'Testteam B'),
            ),
          ],
        ),
        eigenTeamIds: {305},
      );

      expect(item.soort, RoosterSoort.match);
      expect(item.statusLabel, 'In afwachting');
      expect(item.teamNamen, ['Testteam A', 'Testteam B']);
      expect(item.event, isNull);
      expect(item.sleutel, 'match:33');
    });
  });
}
