# Team Management App — werkregels voor deze codebase

Flutter-app voor het vak Cross-Platform Development (WFSDAD.CPD.01), Windesheim.
Opdrachtgever in de casus: Connect-IT. Student: Pedro Eduardo Cardoso.

**Lees vóór je iets bouwt:** `../SCOPE-en-REQUIREMENTS.md` en `../API-overzicht.md`.

---

## 1. Wat dit project is

Een cross-platform team management- en planningsapp: teams, rollen, events, matches tussen teams,
uitnodigingen via QR-code en een routeplanner. De back-end bestaat al en wordt niet gebouwd.

- **Doelplatformen:** web en Android, uit één codebase
- **Back-end:** `https://team-managment-api.dendrowen.com/api/v2` — bestaande REST-API, OpenAPI 3.0
- **Deadline:** week van 17 augustus 2026

## 2. Harde regels

1. **Nederlands** in documentatie en commit-berichten; **Engels** in code, klassenamen en variabelen
2. **Elke wijziging hoort bij een requirement.** Verwijs in de commit naar het nummer, bijvoorbeeld `FR-04`
3. **Geen HTTP-aanroepen in widgets.** Schermen praten met repositories, repositories met de ApiClient
4. **Geen secrets in de code.** Tokens gaan in `flutter_secure_storage`, base-URL in een configbestand
5. **Geen nieuwe features bedenken.** Staat het niet in `SCOPE-en-REQUIREMENTS.md`, dan bouw je het niet.
   Zie je iets ontbreken, meld het en wacht
6. **`flutter analyze` moet schoon zijn** voordat je een pull request opent
7. **Elke feature krijgt minimaal één test.** Logica als unit test, scherm als widget test

## 3. Mappenstructuur

```
lib/
  main.dart
  core/
    config.dart          base-URL en constanten
    theme.dart           kleuren en typografie
    router.dart          routes
    errors.dart          foutmodellen en afhandeling
  data/
    api/api_client.dart  HTTP, token toevoegen, foutvertaling
    models/              Team, Event, Match, Invite, User
    repositories/        AuthRepository, TeamRepository, EventRepository, MatchRepository
  features/
    auth/                registreren, inloggen
    teams/               overzicht, detail, QR tonen, QR scannen
    events/              aanmaken, detail
    schedule/            teamrooster, persoonlijk rooster
  shared/                herbruikbare widgets
test/
  unit/                  repositories en logica, met een testdubbel voor de ApiClient
  widget/                schermen
```

Elke repository heeft een interface, zodat er in tests een testdubbel voor in de plaats kan.
Dat is niet netjes-om-het-netjes: NFR-06 eist testbaarheid zonder netwerk.

## 4. Git

- `main` is stabiel, `dev` is de integratietak
- Feature branches heten `feature/FR-04-team-aanmaken`
- Commit-formaat: `FR-04 Team aanmaken via API`
- Naar `dev` alleen via een pull request; naar `main` alleen aan het einde van een sprint
- De repository is **private**; `windesheim-bram` heeft leestoegang

## 5. Waar je op moet letten bij deze API

- Inloggen gaat op **naam en wachtwoord**, niet op e-mail
- Een gebruiker toevoegen aan een team gaat op **userId**, niet op naam
- Er is **geen QR-endpoint**: de code bevat het team-id, de app roept daarna `addUser` aan
- Een eventlocatie is een **coördinatenpaar**, geen adres
- Er is **geen endpoint voor het persoonlijk rooster**; dat stel je in de app samen uit `GET /events`,
  inclusief ontdubbelen wanneer je via twee teams bij dezelfde match hoort
- `GET /dev/expired-token` bestaat om je foutafhandeling bij een verlopen sessie te testen

## 6. Definition of Done

Een item is af als:

- De functionaliteit werkt op **web én Android**
- De acceptatiecriteria uit het requirement zijn afgevinkt
- Er minimaal één test bij zit, en de suite groen is
- `flutter analyze` geen waarschuwingen geeft
- De code via een pull request op `dev` staat
- Het SDD is bijgewerkt als het ontwerp veranderde

## 7. Documentatie die meegroeit

Deze documenten zijn levend en horen bij de oplevering:

| Document | Wat erin hoort |
|---|---|
| SDD | Requirements, FO met activity diagrams en wireframes, TO met UML en datamodel, testplan |
| Adviesrapport | Elke keuze met de overwogen alternatieven en de reden |
| Scrum-artifacts | Per sprint: backlog, planning, review, retrospective, testrapport |

Maak je een technische keuze — een pakket, een patroon, een oplossing voor een probleem — noteer die dan
meteen als kort advies. Achteraf reconstrueren kost meer tijd en levert zwakkere onderbouwing op.
