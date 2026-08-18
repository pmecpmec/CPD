# Advies — matches aanmaken en uitnodigingen beantwoorden (FR-15, FR-16)

Korte vastlegging van de keuzes uit taak **T-10**.

## Het probleem

Een match is een event tussen teams. De API heeft geen status op de match
zelf: die zit per uitnodiging in `invites[]`. Het id om te antwoorden staat
niet in die lijst, alleen in `GET /matches/invites` aan de kant van de
ontvanger.

## Overwogen alternatieven

| Alternatief | Waarom niet |
|---|---|
| Status op de match afleiden en opslaan | De API heeft dat veld niet. Een eigen status zou bij de eerstvolgende GET weer weg zijn |
| Invite-id raden uit de volgorde in `invites[]` | De meting toont geen id in die lijst. Alleen `GET /matches/invites` levert hem |
| Match-schermen in het teamdetail | Die file hoort bij een andere taak. De ingang staat daarom op het teamoverzicht |
| Roosters bijwerken in deze taak | Expliciet buiten scope: T-08 en T-09 doen dat |

## De keuze

- **Overgangen** in één functie: `pending → accepted/declined` en
  `accepted → canceled`. De UI toont alleen wat die functie teruggeeft.
- **Invite-id** komt uit `GET /matches/invites`. De titel van de match komt
  uit `GET /matches`, gekoppeld op `matchId`.
- **Aanmaken** mag alleen een beheerder. Het formulier toont de teams waarvan
  de gebruiker eigenaar is, plus een lijst andere teams om uit te nodigen.
