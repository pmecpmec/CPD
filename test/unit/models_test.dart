import 'dart:convert';

import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests voor de datamodellen (T-01).
///
/// Elk JSON-fragment hieronder is letterlijk overgenomen uit een echt antwoord
/// van `https://team-managment-api.dendrowen.com/api/v2`, gemeten op
/// 12 augustus 2026 met `dart run tool/api_verkenning.dart`. De volledige
/// uitvoer staat in `docs/api-waargenomen-gedrag.md`.
///
/// De fragmenten zijn het uitgepakte `data`-object: de envelop
/// `{"message": ..., "data": ..., "error": ...}` haalt de `ApiClient` er al af.
/// Verandert de API, dan hoort eerst dit bestand mee te veranderen.
void main() {
  Map<String, dynamic> json(String tekst) =>
      jsonDecode(tekst) as Map<String, dynamic>;

  group('User', () {
    // Uit POST /auth/login.
    test('leest id en naam uit het inlogantwoord', () {
      final user = User.fromJson(
        json('''
        {
          "id": 92,
          "name": "testuser068393a",
          "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OTIsIm5hbWUi"
        }
        '''),
      );

      expect(user.id, 92);
      expect(user.name, 'testuser068393a');
    });
  });

  group('Team', () {
    // Uit POST /teams/306/addUser — het team met beheerder en één gewoon lid.
    const teamMetTweeLeden = '''
    {
      "id": 306,
      "name": "Testteam A 068393",
      "description": "Aangemaakt door het verkenningsscript",
      "ownerId": 92,
      "members": [
        { "id": 92, "name": "testuser068393a" },
        { "id": 93, "name": "testuser068393b" }
      ],
      "metadata": { "Icon": "calendar_today" },
      "createdAt": "2026-08-12T13:01:58.000Z",
      "updatedAt": "2026-08-12T13:01:58.000Z"
    }
    ''';

    test('leest alle velden, met de leden onder de sleutel members', () {
      final team = Team.fromJson(json(teamMetTweeLeden));

      expect(team.id, 306);
      expect(team.name, 'Testteam A 068393');
      expect(team.description, 'Aangemaakt door het verkenningsscript');
      expect(team.ownerId, 92);
      expect(team.metadata, {'Icon': 'calendar_today'});
      expect(team.iconNaam, 'calendar_today');
      expect(team.members.map((lid) => lid.id), [92, 93]);
      expect(team.members.first.name, 'testuser068393a');
    });

    test('leidt de rol af uit ownerId, want de leden hebben er geen', () {
      final team = Team.fromJson(json(teamMetTweeLeden));

      expect(team.isBeheerder(92), isTrue, reason: 'de eigenaar is beheerder');
      expect(team.isBeheerder(93), isFalse, reason: 'lid 93 is geen eigenaar');
      expect(team.isBeheerder(null), isFalse);

      expect(team.isLid(93), isTrue);
      expect(team.isLid(999), isFalse);
    });

    test('houdt null in description en metadata leeg', () {
      // Uit GET /teams: oudere teams hebben deze velden niet gevuld.
      final team = Team.fromJson(
        json('''
        {
          "id": 102,
          "name": "test",
          "description": null,
          "ownerId": 33,
          "members": [ { "id": 33, "name": "testgebruiker2" } ],
          "metadata": null
        }
        '''),
      );

      expect(team.description, isEmpty);
      expect(team.metadata, isEmpty);
      expect(team.iconNaam, isNull);
      expect(team.members, hasLength(1));
    });

    test('laat ownerId leeg als de API het weglaat', () {
      // Uit GET /matches/33: het team komt daar zonder ownerId mee. De rol is
      // dan onbekend en mag nooit als beheerder gelden.
      final team = Team.fromJson(
        json('''
        {
          "id": 306,
          "name": "Testteam A 068393",
          "members": [
            { "id": 92, "name": "testuser068393a" },
            { "id": 93, "name": "testuser068393b" }
          ]
        }
        '''),
      );

      expect(team.ownerId, isNull);
      expect(team.isBeheerder(92), isFalse);
      expect(team.isLid(92), isTrue);
    });
  });

  group('Event', () {
    // Uit GET /events.
    const eventJson = '''
    {
      "id": 88,
      "title": "Testafspraak",
      "description": "Aangemaakt door het verkenningsscript",
      "datetimeStart": "2026-08-13T13:01:58.000Z",
      "datetimeEnd": "2026-08-13T15:01:58.000Z",
      "location": { "latitude": 52.5168, "longitude": 5.4714 },
      "teamId": 306,
      "metadata": { "locatieNaam": "Windesheim Almere" },
      "createdBy": 92,
      "createdAt": "2026-08-12T13:01:58.000Z",
      "updatedAt": "2026-08-12T13:01:58.000Z",
      "team": {
        "id": 306,
        "name": "Testteam A 068393",
        "description": "Aangemaakt door het verkenningsscript",
        "ownerId": 92,
        "members": [
          { "id": 92, "name": "testuser068393a" },
          { "id": 93, "name": "testuser068393b" }
        ],
        "metadata": { "Icon": "calendar_today" }
      }
    }
    ''';

    test('leest titel, tijden, locatie en team', () {
      final event = Event.fromJson(json(eventJson));

      expect(event.id, 88);
      expect(event.title, 'Testafspraak');
      expect(event.description, 'Aangemaakt door het verkenningsscript');
      expect(event.teamId, 306);
      expect(event.location?.latitude, 52.5168);
      expect(event.location?.longitude, 5.4714);
      expect(event.locatieNaam, 'Windesheim Almere');
      expect(event.team?.name, 'Testteam A 068393');
      expect(
        event.team?.isBeheerder(92),
        isTrue,
        reason: 'het meegestuurde team heeft ownerId, dus de rol is bekend',
      );
    });

    test('leest de tijden als UTC en zet ze om naar lokale tijd', () {
      final event = Event.fromJson(json(eventJson));

      expect(event.start.isUtc, isFalse, reason: 'lokaal voor weergave');
      expect(
        event.start.toUtc(),
        DateTime.utc(2026, 8, 13, 13, 1, 58),
        reason: 'de API levert UTC met een Z-achtervoegsel',
      );
      expect(event.end.toUtc(), DateTime.utc(2026, 8, 13, 15, 1, 58));
      expect(event.end.isAfter(event.start), isTrue);
    });

    test('stuurt de tijden als UTC terug naar de API', () {
      final event = Event.fromJson(json(eventJson));
      final body = event.toJson();

      expect(body['datetimeStart'], endsWith('Z'));
      expect(
        DateTime.parse(body['datetimeStart'] as String),
        DateTime.utc(2026, 8, 13, 13, 1, 58),
      );
      expect(body['teamId'], 306);
      expect(body['location'], {'latitude': 52.5168, 'longitude': 5.4714});
    });

    test('laat de locatie leeg wanneer die ontbreekt', () {
      final event = Event.fromJson(
        json('''
        {
          "id": 1,
          "title": "Zonder locatie",
          "datetimeStart": "2026-08-13T13:01:58.000Z",
          "datetimeEnd": "2026-08-13T15:01:58.000Z",
          "teamId": 306,
          "metadata": null
        }
        '''),
      );

      expect(event.location, isNull, reason: 'FR-17: dan geen routeknop');
      expect(event.team, isNull);
      expect(event.metadata, isEmpty);
    });
  });

  group('Match', () {
    // Uit GET /matches/33, vóór het accepteren.
    const matchPending = '''
    {
      "id": 33,
      "title": "Testmatch",
      "description": "Aangemaakt door het verkenningsscript",
      "datetimeStart": "2026-08-14T13:01:58.000Z",
      "datetimeEnd": "2026-08-14T15:01:58.000Z",
      "location": { "latitude": 52.5168, "longitude": 5.4714 },
      "metadata": { "instructions": "Neem je laptop mee" },
      "teamId": 306,
      "team": {
        "id": 306,
        "name": "Testteam A 068393",
        "members": [
          { "id": 92, "name": "testuser068393a" },
          { "id": 93, "name": "testuser068393b" }
        ]
      },
      "invites": [
        {
          "teamId": 305,
          "status": "pending",
          "team": {
            "id": 305,
            "name": "Testteam B 068393",
            "members": [ { "id": 93, "name": "testuser068393b" } ]
          }
        }
      ],
      "createdBy": 92,
      "createdAt": "2026-08-12T13:01:58.000Z",
      "updatedAt": "2026-08-12T13:01:58.000Z"
    }
    ''';

    test('legt het organiserende team vast in teamId en team', () {
      final match = Match.fromJson(json(matchPending));

      expect(match.id, 33);
      expect(match.title, 'Testmatch');
      expect(match.teamId, 306, reason: 'het organiserende team');
      expect(match.team?.name, 'Testteam A 068393');
      expect(match.location?.latitude, 52.5168);
      expect(match.metadata, {'instructions': 'Neem je laptop mee'});
      expect(match.start.toUtc(), DateTime.utc(2026, 8, 14, 13, 1, 58));
      expect(match.end.toUtc(), DateTime.utc(2026, 8, 14, 15, 1, 58));
    });

    test('houdt de status per uitnodiging bij, niet op de match zelf', () {
      final match = Match.fromJson(json(matchPending));

      expect(match.invites, hasLength(1));
      expect(match.invites.single.teamId, 305);
      expect(match.invites.single.status, InviteStatus.pending);
      expect(match.invites.single.teamNaam, 'Testteam B 068393');
      expect(match.invites.single.id, isNull, reason: 'zit niet in een match');

      expect(match.statusVoorTeam(305), InviteStatus.pending);
      expect(
        match.statusVoorTeam(306),
        isNull,
        reason: 'de organisator heeft geen uitnodiging',
      );
      expect(match.alleGeaccepteerd, isFalse);
    });

    test('noemt alle betrokken teams, organisator eerst', () {
      final match = Match.fromJson(json(matchPending));

      expect(match.teamIds, [306, 305]);
    });

    test('ziet een match als geaccepteerd als elke uitnodiging dat is', () {
      // Uit GET /matches/33 ná POST /matches/invites/32 met status accepted.
      final match = Match.fromJson(
        json(
          matchPending.replaceFirst(
            '"status": "pending"',
            '"status": "accepted"',
          ),
        ),
      );

      expect(match.invites.single.status, InviteStatus.accepted);
      expect(match.alleGeaccepteerd, isTrue);
    });

    test('ziet een match met een afwijzing niet als geaccepteerd', () {
      // Uit GET /matches: er staan matches met een afgewezen uitnodiging in.
      final match = Match.fromJson(
        json(
          matchPending.replaceFirst(
            '"status": "pending"',
            '"status": "declined"',
          ),
        ),
      );

      expect(match.invites.single.status, InviteStatus.declined);
      expect(match.alleGeaccepteerd, isFalse);
    });

    test('een match zonder uitnodigingen geldt niet als geaccepteerd', () {
      final match = Match.fromJson(
        json('''
        {
          "id": 34,
          "title": "Zonder tegenstander",
          "datetimeStart": "2026-08-14T13:01:58.000Z",
          "datetimeEnd": "2026-08-14T15:01:58.000Z",
          "metadata": null,
          "teamId": 306,
          "invites": []
        }
        '''),
      );

      expect(match.invites, isEmpty);
      expect(match.alleGeaccepteerd, isFalse);
      expect(match.teamIds, [306]);
    });
  });

  group('MatchInvite', () {
    test('leest de vorm uit GET /matches/invites, met invite-id', () {
      // Deze vorm is de enige plek waar het invite-id staat; dat id is nodig om
      // te accepteren of af te wijzen (FR-16).
      final invite = MatchInvite.fromJson(
        json('{ "id": 32, "matchId": 33, "status": "pending" }'),
      );

      expect(invite.id, 32);
      expect(invite.matchId, 33);
      expect(invite.status, InviteStatus.pending);
      expect(invite.teamId, isNull, reason: 'deze vorm noemt geen team');
      expect(invite.team, isNull);
    });

    test('leest het antwoord op een geaccepteerde uitnodiging', () {
      // Uit POST /matches/invites/32 met {"status": "accepted"}.
      final invite = MatchInvite.fromJson(
        json('{ "id": 32, "matchId": 33, "status": "accepted" }'),
      );

      expect(invite.status, InviteStatus.accepted);
      expect(invite.status.label, 'Geaccepteerd');
    });

    test('valt terug op pending bij een onbekende status', () {
      final invite = MatchInvite.fromJson(
        json('{ "id": 1, "status": "iets" }'),
      );

      expect(invite.status, InviteStatus.pending);
    });
  });

  group('GeoLocatie', () {
    test('leest coördinaten, ook een hele graad zonder decimalen', () {
      // Uit GET /matches: latitude en longitude staan daar als 0.
      final locatie = GeoLocatie.fromJson(
        json('{ "latitude": 0, "longitude": 0 }'),
      );

      expect(locatie.latitude, 0);
      expect(locatie.longitude, 0);
      expect(locatie.toJson(), {'latitude': 0.0, 'longitude': 0.0});
    });
  });
}
