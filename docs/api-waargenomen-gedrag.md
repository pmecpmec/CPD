# Waargenomen gedrag van de Team Management API

Meting van **12 augustus 2026**, uitgevoerd met `dart run tool/api_verkenning.dart` tegen
`https://team-managment-api.dendrowen.com/api/v2`. Dit document hoort bij taak **T-01** en is de bron
voor de veldnamen in `lib/data/models/models.dart` en voor de JSON-fragmenten in
`test/unit/models_test.dart`.

Alles hieronder is echt teruggekomen van de server. Waar de OpenAPI-documentatie of
`../../API-overzicht.md` iets anders zegt, is de meting leidend en staat het verschil erbij vermeld.

Het script gebruikt twee testgebruikers, omdat een aantal vragen niet met één account te beantwoorden
is: krijgt een lid dat géén eigenaar is een rol mee, en hoe ziet een uitnodiging eruit aan de kant van
het uitgenodigde team.

| Gegeven | Waarde in deze meting |
|---|---|
| Gebruiker A (organisator) | `testuser068393a`, id **92** |
| Gebruiker B (lid en tegenstander) | `testuser068393b`, id **93** |
| Team A | id **306** |
| Team B | id **305** |
| Event | id **88** |
| Match | id **33**, uitnodiging id **32** |

Lange lijsten zijn in de uitvoer afgekapt op drie items; de structuur is dan nog volledig zichtbaar.

---

## Samenvatting — de antwoorden op de vragen uit T-01

| Vraag | Antwoord |
|---|---|
| Onder welke sleutel staan de teamleden? | **`members`**, een lijst van `{"id", "name"}`. Niet `users` of `teamUsers` |
| Krijgt een lid een rol mee? | **Nee.** Een lid heeft alleen `id` en `name`. De beheerder blijkt uit **`ownerId`** op het team |
| Hoe legt een match de teams vast? | Organisator in **`teamId`** (plus het hele team in `team`); uitgenodigde teams in **`invites`**, elk met `teamId`, `status` en `team` |
| Waar staat de status van een match? | **Per uitnodiging**, in `invites[].status`. De match zelf heeft géén statusveld |
| Formaat van `datetimeStart` en `datetimeEnd` | ISO 8601 in **UTC** met `Z`-achtervoegsel en milliseconden: `2026-08-13T13:01:58.000Z` |

### Wat dat betekent voor de modellen

- `Team` heeft `ownerId` gekregen. Dat veld is de enige bron voor het onderscheid beheerder/lid
  (FR-06 tot FR-08). `Team.isBeheerder(userId)` doet niets anders dan `ownerId == userId`.
- `Team.members` leest nu alleen `members`; de gok op `users` is eruit.
- `Event` heeft het meegestuurde `team` erbij. Voor het persoonlijk rooster (FR-14) is er dus geen
  extra aanroep nodig om de teamnaam bij een item te zetten.
- `Match` had een veld `status` en een lijst `teams`. Beide bestaan niet. Er is nu `teamId`, `team`,
  `end` en een lijst `invites` van `MatchInvite`, plus `alleGeaccepteerd` en `statusVoorTeam()` voor
  FR-13 en FR-16.
- `MatchInvite` is nieuw en leest beide vormen waarin de API een uitnodiging laat zien, zie stap 15 en 18.

### Twee dingen om op te letten

1. **Het foutveld heet `error`, niet `errors`** — en het is een lijst. Zie stap 3, 21 en 22.
   `ApiClient._serverMelding` zoekt eerst een lijst in `errors` en daarna een tekst in `error`; op dit
   antwoord past geen van beide, dus valt de app terug op een algemene melding en gaat de tekst van de
   server verloren ("Username already taken" bij FR-01). Buiten de scope van T-01, dus niet aangepast:
   `lib/data/api/api_client.dart` en `test/unit/*` horen bij een andere taak.
2. **`GET /teams` en `GET /matches` geven alles van de hele server** — 94 teams en 23 matches van
   andere gebruikers, inclusief ledenlijsten. `GET /events` is wél afgeschermd en gaf alleen het event
   van team A. De privacy-eis (FR-06) moet de app dus zelf afdwingen; de API doet dat bij teams en
   matches niet.

---

## Antwoordformaat

Elk antwoord zit in dezelfde envelop. Bij succes:

```json
{ "message": "Success", "data": { }, "error": null }
```

`message` is niet altijd letterlijk `"Success"`: bij het aanmaken van een event staat er
`"Event created successfully"`, bij een match `"Match created successfully"`, bij het toevoegen van een
lid `"User added to the team successfully"`. De app leest `message` niet, dus dat maakt niets uit.

Bij een fout:

```json
{ "message": "Error", "data": null, "error": ["Team not found"] }
```

---

## 1. `POST /auth/register` — 201

Verzoek: `{"name":"testuser068393a","password":"TestWachtwoord123"}`

```json
{
  "message": "Success",
  "data": {
    "id": 92,
    "name": "testuser068393a"
  },
  "error": null
}
```

## 2. `POST /auth/login` — 200

Verzoek: `{"name":"testuser068393a","password":"TestWachtwoord123"}`

```json
{
  "message": "Success",
  "data": {
    "id": 92,
    "name": "testuser068393a",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OTIsIm5hbWUiOiJ0ZXN0dXNlcjA2ODM5M2EiLCJpYXQiOjE3ODY1Mzk3MTgsImV4cCI6MTc4OTEzMTcxOH0.0-jFf6SoYinrhMJjUYr9zq5CeK13KiDbx4EpKrR_V2M"
  },
  "error": null
}
```

Het token is een JWT en gaat mee als `Authorization: Bearer <token>`. De payload bevat `id`, `name`,
`iat` en `exp`; de geldigheidsduur is **30 dagen** (`exp - iat` = 2 592 000 seconden). Het gebruikers-id
komt in hetzelfde antwoord mee, wat nodig is om jezelf via een QR-code aan een team toe te voegen (FR-10).

## 3. `POST /auth/register` met een bestaande naam — 400

```json
{
  "message": "Error",
  "data": null,
  "error": [
    "Username already taken"
  ]
}
```

Let op de sleutel: **`error`**, met een lijst erin. `API-overzicht.md` noemt `errors`; dat is niet wat
de server stuurt.

## 4 en 5. Tweede gebruiker registreren en inloggen — 201 en 200

Zelfde vorm als stap 1 en 2; gebruiker B krijgt id **93**.

## 6. `POST /teams` als gebruiker B — 201

Verzoek: `{"name":"Testteam B 068393","description":"Tegenstander voor de match","metadata":{"Icon":"shield"}}`

```json
{
  "message": "Success",
  "data": {
    "id": 305,
    "name": "Testteam B 068393",
    "description": "Tegenstander voor de match",
    "ownerId": 93,
    "members": [
      { "id": 93, "name": "testuser068393b" }
    ],
    "metadata": { "Icon": "shield" },
    "createdAt": "2026-08-12T13:01:58.000Z",
    "updatedAt": "2026-08-12T13:01:58.000Z"
  },
  "error": null
}
```

De aanmaker staat direct als `ownerId` én als enige lid in `members`. Dat bevestigt FR-04: wie een team
aanmaakt, is er beheerder van.

## 7. `POST /teams` als gebruiker A — 201

Zelfde vorm; team A krijgt id **306**, `ownerId` 92, `metadata` `{"Icon":"calendar_today"}`.

## 8. `GET /teams` — 200

```json
{
  "message": "Success",
  "data": [
    {
      "id": 79,
      "name": "Team Sigma",
      "description": "This is a team",
      "ownerId": 7,
      "members": [
        { "id": 7, "name": "Beamer" },
        { "id": 1, "name": "User" }
      ],
      "metadata": { "Icon": "calendar_today" },
      "createdAt": "2025-10-06T10:18:01.000Z",
      "updatedAt": "2025-10-06T10:18:01.000Z"
    },
    {
      "id": 100,
      "name": "New team with user",
      "description": "While logged in",
      "ownerId": 28,
      "members": [
        { "id": 28, "name": "Testv2" }
      ],
      "metadata": null,
      "createdAt": "2025-10-10T13:37:25.000Z",
      "updatedAt": "2025-10-10T17:16:50.000Z"
    },
    {
      "id": 102,
      "name": "test",
      "description": null,
      "ownerId": 33,
      "members": [
        { "id": 33, "name": "testgebruiker2" }
      ],
      "metadata": null,
      "createdAt": "2025-10-13T08:33:38.000Z",
      "updatedAt": "2025-10-13T08:33:38.000Z"
    },
    "... nog 91 item(s), afgekapt"
  ],
  "error": null
}
```

Drie observaties:

- Dit zijn **alle 94 teams op de server**, niet alleen die van de ingelogde gebruiker. Het
  teamoverzicht moet zelf filteren op lidmaatschap, en de privacy-eis (FR-06) is een zaak van de app.
- `description` en `metadata` kunnen **`null`** zijn. De modellen maken daar een lege tekst en een lege
  map van.
- Ook van teams waar je niet bij hoort komt de volledige ledenlijst mee. Dat is een bevinding voor het
  adviesrapport, geen reden om die gegevens te tonen.

## 9. `GET /teams/306` — 200

```json
{
  "message": "Success",
  "data": {
    "id": 306,
    "name": "Testteam A 068393",
    "description": "Aangemaakt door het verkenningsscript",
    "ownerId": 92,
    "members": [
      { "id": 92, "name": "testuser068393a" }
    ],
    "metadata": { "Icon": "calendar_today" },
    "createdAt": "2026-08-12T13:01:58.000Z",
    "updatedAt": "2026-08-12T13:01:58.000Z"
  },
  "error": null
}
```

## 10. `POST /teams/306/addUser` — 200

Verzoek: `{"userId":93}`

```json
{
  "message": "User added to the team successfully",
  "data": {
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
  },
  "error": null
}
```

**Dit is het beslissende antwoord voor de rolvraag.** Team A heeft nu twee leden: de beheerder (92) en
een gewoon lid (93). Beide staan er identiek in, met alleen `id` en `name`. Er is geen `role`, `isAdmin`
of iets dergelijks. Wie beheerder is, is alleen te bepalen door `ownerId` te vergelijken met het eigen
gebruikers-id.

Het antwoord geeft het bijgewerkte team terug, dus na het toevoegen is een extra `GET` niet nodig.

## 11. `GET /teams/306` opnieuw — 200

Identiek aan het antwoord van stap 10, dus het toevoegen is echt verwerkt.

## 12. `POST /events` — 201

Verzoek:

```json
{
  "title": "Testafspraak",
  "description": "Aangemaakt door het verkenningsscript",
  "datetimeStart": "2026-08-13T13:01:58.685572Z",
  "datetimeEnd": "2026-08-13T15:01:58.685572Z",
  "location": { "latitude": 52.5168, "longitude": 5.4714 },
  "teamId": 306,
  "metadata": { "locatieNaam": "Windesheim Almere" }
}
```

Antwoord:

```json
{
  "message": "Event created successfully",
  "data": {
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
  },
  "error": null
}
```

Over datum en tijd:

- De server neemt UTC aan en geeft UTC terug, met een `Z` en drie decimalen.
- **Sub-secondes gaan verloren**: er ging `13:01:58.685572Z` in en er kwam `13:01:58.000Z` uit. De tijd
  wordt afgekapt op hele seconden. Voor een agenda maakt dat niets uit, maar een test moet er niet op
  rekenen dat de heen- en terugweg exact gelijk zijn.
- Er is geen tijdzone-informatie buiten die `Z`. De app rekent bij het tonen om naar de tijdzone van
  het apparaat (`toLocal()`) en stuurt bij het opslaan altijd `toUtc()`.
- `metadata` gaat ongewijzigd heen en terug, dus `locatieNaam` is een bruikbare plek voor een leesbare
  plaatsnaam bij de coördinaten (T-06).

Het `team`-object komt mee, maar zonder `createdAt` en `updatedAt`.

## 13. `GET /events` — 200

```json
{
  "message": "Success",
  "data": [
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
  ],
  "error": null
}
```

Precies één event: dat van team A. Anders dan `GET /teams` en `GET /matches` is dit endpoint dus **wel**
afgeschermd op lidmaatschap. Het levert de events van álle teams van de gebruiker, wat de basis is voor
het persoonlijk rooster (FR-14). Matches zitten er niet bij; die moeten los worden opgehaald.

## 14. `POST /matches` — 201

Verzoek:

```json
{
  "title": "Testmatch",
  "description": "Aangemaakt door het verkenningsscript",
  "datetimeStart": "2026-08-14T13:01:58.685572Z",
  "datetimeEnd": "2026-08-14T15:01:58.685572Z",
  "location": { "latitude": 52.5168, "longitude": 5.4714 },
  "teamId": 306,
  "metadata": { "instructions": "Neem je laptop mee" },
  "invites": [ { "teamId": 305 } ]
}
```

Antwoord:

```json
{
  "message": "Match created successfully",
  "data": {
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
      "description": "Aangemaakt door het verkenningsscript",
      "ownerId": 92,
      "members": [
        { "id": 92, "name": "testuser068393a" },
        { "id": 93, "name": "testuser068393b" }
      ],
      "metadata": { "Icon": "calendar_today" }
    },
    "invites": [
      {
        "teamId": 305,
        "status": "pending",
        "team": {
          "id": 305,
          "name": "Testteam B 068393",
          "description": "Tegenstander voor de match",
          "ownerId": 93,
          "members": [
            { "id": 93, "name": "testuser068393b" }
          ],
          "metadata": { "Icon": "shield" }
        }
      }
    ],
    "createdBy": 92,
    "createdAt": "2026-08-12T13:01:58.000Z",
    "updatedAt": "2026-08-12T13:01:58.000Z"
  },
  "error": null
}
```

Een match is dus een event met een `invites`-lijst erbij, en met het organiserende team in `teamId`.
Een nieuwe uitnodiging staat meteen op `pending`, wat FR-15 vraagt. Er is **geen statusveld op de match
zelf**; het model leidt "alle teams hebben geaccepteerd" af uit de uitnodigingen.

## 15. `GET /matches/33` — 200

```json
{
  "message": "Success",
  "data": {
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
          "members": [
            { "id": 93, "name": "testuser068393b" }
          ]
        }
      }
    ],
    "createdBy": 92,
    "createdAt": "2026-08-12T13:01:58.000Z",
    "updatedAt": "2026-08-12T13:01:58.000Z"
  },
  "error": null
}
```

Hier zit een valkuil: **de teams in dit antwoord missen `ownerId`, `description` en `metadata`.** In het
lijstantwoord van `GET /matches` en in de antwoorden van `/events` zitten die velden er wél in. Daarom is
`Team.ownerId` in het model nullable en levert `isBeheerder()` `false` zolang het onbekend is: een
onvolledig antwoord mag nooit per ongeluk beheerdersrechten opleveren. Wie de rol zeker moet weten, haalt
het team los op met `GET /teams/{id}`.

De uitnodiging heeft hier **geen `id`**. Het id om te antwoorden komt uit `GET /matches/invites`, zie
stap 18.

## 16. `GET /matches` — 200

```json
{
  "message": "Success",
  "data": [
    {
      "id": 1,
      "title": "Friendly Match",
      "description": "A friendly match between teams",
      "datetimeStart": "2024-09-01T10:00:00.000Z",
      "datetimeEnd": "2024-09-01T12:00:00.000Z",
      "location": { "latitude": 37.7749, "longitude": -122.4194 },
      "metadata": { "instructions": "Bring your laptop" },
      "teamId": 109,
      "team": {
        "id": 109,
        "name": "gekkie team",
        "description": "dit is een test team",
        "ownerId": 34,
        "members": [
          { "id": 34, "name": "gekkie123" }
        ],
        "metadata": null
      },
      "invites": [
        {
          "teamId": 108,
          "status": "accepted",
          "team": {
            "id": 108,
            "name": "Test",
            "description": "Nee",
            "ownerId": 2,
            "members": [
              { "id": 2, "name": "TestUser" },
              { "id": 34, "name": "gekkie123" }
            ],
            "metadata": null
          }
        }
      ],
      "createdBy": 34,
      "createdAt": "2025-11-06T15:44:28.000Z",
      "updatedAt": "2025-11-06T15:44:28.000Z"
    },
    "... nog 22 item(s), afgekapt"
  ],
  "error": null
}
```

Drie observaties:

- Ook dit endpoint geeft **alle 23 matches op de server**, niet alleen die van de eigen teams — terwijl
  de documentatie "alle matches waar de gebruiker lid of uitgenodigd is" belooft. Het rooster moet dus
  zelf filteren op de team-id's van de gebruiker.
- In dit lijstantwoord hebben de teams wél `ownerId`, `description` en `metadata`. Inconsistent met
  stap 15.
- Voorkomende statussen in de bestaande gegevens: `pending`, `accepted` en `declined`. `canceled` kwam
  niet voor.
- Eén van de matches in de lijst (id 11) heeft `location` `{"latitude": 0, "longitude": 0}`. Technisch
  geldig, inhoudelijk onzin; de routeplanner moet er niet op stuklopen.

## 17. `GET /matches/invites` als gebruiker A — 200

```json
{
  "message": "Success",
  "data": [],
  "error": null
}
```

Leeg, terwijl A de match wél organiseert. Dit endpoint gaat dus alleen over uitnodigingen die je hebt
**ontvangen**, niet over die je hebt verstuurd.

## 18. `GET /matches/invites` als gebruiker B — 200

```json
{
  "message": "Success",
  "data": [
    {
      "id": 32,
      "matchId": 33,
      "status": "pending"
    }
  ],
  "error": null
}
```

Dit is een **andere vorm van hetzelfde begrip** dan de `invites` in een match: hier staat wel het
`id`, maar geen team en geen matchgegevens. Alleen via dit endpoint is het invite-id te krijgen, en dat
is nodig om te accepteren of af te wijzen (FR-16). Wie de titel of de datum van de match wil tonen bij
een openstaande uitnodiging, moet die er met `GET /matches/{matchId}` bij halen.

`MatchInvite.fromJson` leest beide vormen: de velden die de ene vorm niet levert, blijven `null`.

## 19. `POST /matches/invites/32` — 200

Verzoek: `{"status":"accepted"}`

```json
{
  "message": "Invite status updated to accepted successfully",
  "data": {
    "id": 32,
    "matchId": 33,
    "status": "accepted"
  },
  "error": null
}
```

Het antwoord bevat alleen de uitnodiging, niet de bijgewerkte match. Na het accepteren moet de app de
match dus opnieuw ophalen om het rooster te verversen.

## 20. `GET /matches/33` na het accepteren — 200

Identiek aan stap 15, met één verschil:

```json
"invites": [
  {
    "teamId": 305,
    "status": "accepted",
    "team": { "id": 305, "name": "Testteam B 068393", "members": [ { "id": 93, "name": "testuser068393b" } ] }
  }
]
```

De overgang `pending → accepted` werkt en is zichtbaar in de match. Dit is meteen de acceptatietest bij
FR-16.

## 21. `GET /dev/expired-token` — 401

```json
{
  "message": "Error",
  "data": null,
  "error": [
    "Invalid or expired token"
  ]
}
```

Bruikbaar als testcase voor FR-03: de app hoort hierop de sessie te wissen en het inlogscherm te tonen.

## 22. `GET /teams/99999999` — 404

```json
{
  "message": "Error",
  "data": null,
  "error": [
    "Team not found"
  ]
}
```

---

## Wat deze meting níét heeft aangetoond

Eerlijk vermelden hoort erbij; dit zijn de gaten die een volgende taak moet dichten.

- **`PUT` en `DELETE` op events en matches** zijn niet aangeroepen. Het antwoordformaat daarvan is dus
  onbekend, ook of een `DELETE` een leeg antwoord of het verwijderde object teruggeeft. Voor teams is
  dat inmiddels wél gemeten, zie de tweede meting hieronder.
- **De statusovergang `accepted → canceled`** is niet uitgeprobeerd, en `canceled` komt nergens in de
  bestaande gegevens voor. `InviteStatus` kan hem lezen, maar de app leunt er niet op.
- **Een verlopen token bij een echt endpoint**: alleen `/dev/expired-token` is gebruikt.

---

# Tweede meting — de ledenacties van een team

Meting van **12 augustus 2026**, uitgevoerd met `dart run tool/api_verkenning_leden.dart`. Deze meting
hoort bij taak **T-03** en vult de gaten die T-01 openliet: `removeUser`, `leave`, `DELETE /teams/{id}`
en het antwoord op een verboden actie. Dat zijn precies de aanroepen achter FR-07 en FR-08.

| Gegeven | Waarde in deze meting |
|---|---|
| Gebruiker A (beheerder) | `ledentest839267a`, id **94** |
| Gebruiker B (gewoon lid) | `ledentest839267b`, id **95** |
| Team | id **307** |

## Samenvatting

| Vraag | Antwoord |
|---|---|
| Wat geeft `removeUser` terug? | **200** met het bijgewerkte team in `data` — dezelfde vorm als `addUser`. Een extra `GET` is niet nodig |
| Wat geeft `leave` terug? | **200** met het bijgewerkte team, `message` = "You have successfully left the team" |
| Wat doet de API bij een verboden actie? | **403** met een tekst in `error`, bijvoorbeeld "You are not authorized to remove users from this team" |
| Mag de beheerder zelf vertrekken? | **Nee.** 400 met "The team owner cannot remove themselves from the team" |
| Wat geeft `DELETE /teams/{id}` terug? | **200** met `data: null`; daarna geeft `GET /teams/{id}` een 404 |
| Ziet een niet-lid de ledenlijst? | **Ja**, `GET /teams/{id}` geeft ook aan een niet-lid het volledige team, inclusief `members` |

De 403-teksten bevestigen dat `GeenRechtenException` de juiste vertaling is. Let op: de tekst zelf komt
niet bij de gebruiker aan, omdat het foutveld `error` heet en een **lijst** bevat, terwijl
`ApiClient._serverMelding` in `error` een tekst verwacht. De app valt daardoor terug op de standaardtekst
uit `core/errors.dart`. Dat is dezelfde bevinding als in de eerste meting en wordt in een aparte taak
opgelost.

## 7 tot en met 9. Verboden acties als gewoon lid — 403

`POST /teams/307/removeUser` met `{"userId":94}` als gebruiker B:

```json
{
  "message": "Error",
  "data": null,
  "error": [
    "You are not authorized to remove users from this team"
  ]
}
```

`DELETE /teams/307` geeft dezelfde vorm met "You are not authorized to delete this team", en
`PUT /teams/307` met "You are not authorized to update this team". De API bewaakt de rechten dus zelf
op teamniveau — maar niet op leesniveau, zie stap 13.

## 10. `POST /teams/307/leave` als lid — 200

```json
{
  "message": "You have successfully left the team",
  "data": {
    "id": 307,
    "name": "Ledentest 839267",
    "description": "Team voor het meten van removeUser en leave",
    "ownerId": 94,
    "members": [
      { "id": 94, "name": "ledentest839267a" }
    ],
    "metadata": { "Icon": "group" },
    "createdAt": "2026-08-12T13:19:36.000Z",
    "updatedAt": "2026-08-12T13:19:36.000Z"
  },
  "error": null
}
```

Het antwoord bevat het team zónder de vertrokken gebruiker. De app gebruikt dat niet: na het verlaten
gaat de gebruiker terug naar het overzicht.

## 12. Verlaten wat je niet hebt — 400

```json
{
  "message": "Error",
  "data": null,
  "error": [
    "You are not a member of this team"
  ]
}
```

Een 400 en geen 403; de app vertaalt dat naar `ValidatieException`.

## 13. `GET /teams/307` als niet-lid — 200

Het volledige team komt terug, met `ownerId`, `members` en `metadata` — precies zoals bij een lid.
**De API schermt teamgegevens dus niet af op lidmaatschap.** De privacy-eis FR-06 is daarmee volledig
een verantwoordelijkheid van de app: `TeamDetailController` toont de ledenlijst alleen wanneer
`Team.isLid()` waar is, en `TeamsController` laat in het overzicht alleen de eigen teams zien.

## 15. Dubbel toevoegen — 200

`POST /teams/307/addUser` met een gebruiker die al lid is, geeft 200 met een ongewijzigde ledenlijst:
geen fout en geen dubbel lid. Bruikbaar voor T-05, waar een tweede scan van dezelfde QR-code geen fout
mag opleveren.

## 16 en 17. `POST /teams/307/removeUser` als beheerder — 200

```json
{
  "message": "User removed from the team successfully",
  "data": {
    "id": 307,
    "name": "Ledentest 839267",
    "description": "Team voor het meten van removeUser en leave",
    "ownerId": 94,
    "members": [
      { "id": 94, "name": "ledentest839267a" }
    ],
    "metadata": { "Icon": "group" },
    "createdAt": "2026-08-12T13:19:36.000Z",
    "updatedAt": "2026-08-12T13:19:36.000Z"
  },
  "error": null
}
```

Hetzelfde lid nog een keer verwijderen geeft opnieuw 200 met dezelfde inhoud: de aanroep is
idempotent. Omdat het bijgewerkte team meekomt, geeft `TeamRepository.verwijderGebruiker` een `Team`
terug in plaats van `void`.

## 18. De beheerder probeert zelf te vertrekken — 400

```json
{
  "message": "Error",
  "data": null,
  "error": [
    "The team owner cannot remove themselves from the team"
  ]
}
```

Dit bevestigt FR-07: een beheerder kan het team niet verlaten, alleen verwijderen. Het detailscherm
toont hem de knop "Team verlaten" daarom niet; deze 400 is het vangnet, niet de eerste verdediging.

## 19 en 20. `DELETE /teams/307` als beheerder — 200, daarna 404

```json
{ "message": "Success", "data": null, "error": null }
```

Daarna geeft `GET /teams/307` een 404 met "Team not found". De documentatie noemt het een soft delete;
van buitenaf is het team hoe dan ook weg.

## Wat ook deze meting níét heeft aangetoond

- Of een **event of match van een verwijderd team** mee verdwijnt, is niet gecontroleerd.
- Of een verwijderd lid de **events van dat team** meteen kwijt is in `GET /events`, is niet gemeten.
- `PUT /teams/{id}` is alleen als **verboden** actie aangeroepen, nooit met succes als beheerder. Het
  antwoordformaat bij een geslaagde wijziging is dus nog onbekend.
