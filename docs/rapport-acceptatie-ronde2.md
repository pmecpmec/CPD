# Rapport acceptatietesten ronde 2

Uitgevoerd op 18 augustus 2026. Stap 1 tot en met 13: Pedro, overgenomen uit `ACCEPTATIETESTEN-RONDE-2.md` zoals hij ze daar schreef. Stap 14 tot en met 28: Cursor-agent. Niets ingevuld dat niet is gedaan.

Code is niet gewijzigd. Getest tegen de app in `crossplatformdevelopment` (lib gelijk aan `main`). Web: `flutter run -d chrome --web-port 9160`. Android: bestaande emulator `emulator-5554` (AVD `cpd_test`), geen tweede emulator gestart.

Browser-MCP kon geen tab vastzetten (tabs verdwenen meteen). Web-UI is daarom via Chrome CDP op de Flutter-Chrome van poort 9160 bediend.

## Resultatentabel

| AT-nummer | platform | uitkomst | wie | wat gezien |
|---|---|---|---|---|
| AT-04 | web | ok | Pedro | Inloggen als pedroA toont Mijn teams met Team Alpha en Team Beta. Tekst van Pedro: "yes dit klopt". |
| AT-23 (eerste helft) | web | ok | Pedro | Agenda toont de events uit ronde 1 met teamnaam. Tekst van Pedro: "ja klopt". |
| (geen AT, agenda-ververs) | web | ok | Pedro | Nieuw event Verstest stond daarna in de Agenda. Tekst van Pedro: "ja klopt". |
| AT-24 | web | ok | Pedro | Match aangemaakt, status in afwachting. Tekst van Pedro: "yes". |
| AT-25 | web | ok | Pedro | Uitnodiging geaccepteerd, status geaccepteerd. Tekst van Pedro: "yes dit klopt". |
| FR-16 (alleen geldige overgangen) | web | ok | Pedro | Alleen een knop Annuleren, geen accepteren of afwijzen. Tekst van Pedro: "yup alleen annuleren knop". |
| AT-22 | web | ok | Pedro | Match staat in het rooster van Team Alpha. Tekst van Pedro: "ja wedstr staat er tussen". |
| AT-23 (tweede helft) | web | ok | Pedro | Match één keer in de Agenda, beide teamnamen. Tekst van Pedro: "yes klopt". |
| AT-02 | web | (leeg) | Pedro | Pedro heeft bij Uitkomst niets ingevuld. |
| (nieuw, FR-01, melding verdwijnt) | web | (onduidelijk) | Pedro | Tekst van Pedro: "ik zie niks". Geen ok aangenomen. |
| AT-05 | web | ok | Pedro | Fout wachtwoord: melding klopt, blijft op het scherm. Tekst van Pedro: "yes klopt". |
| AT-26 | web | ok | Pedro | Route opent een nieuw tabblad met een kaart. Tekst van Pedro: "yes klopt". |
| Stap 13 (QR klaarzetten) | web | nvt | Pedro | Geen test, voorbereiding. |
| AT-16 | web | nvt | Cursor-agent | Scanscherm opent (titel QR-code scannen). Camera toont een live beeld. Er was geen QR van stap 13 om voor de camera te houden, dus lid worden via scannen is niet afgerond. Zie Stap 14 hieronder. |
| AT-18 | web | nvt | Cursor-agent | Geen andere QR-code voorgehouden. Zonder iets om te scannen is de melding bij een verkeerde code niet te zien. Pedro schreef in het bronbestand bij deze stap "yes"; dat is zijn meting, niet de mijne. |
| AT-15 | web | ok | Cursor-agent | Als pedroB in Team Alpha: naam, omschrijving Zaterdagcompetitie, Leden (2) met pedroA (Beheerder) en pedroB (Jij). Geen knop QR-uitnodiging, geen knop Event aanmaken. Wel Team verlaten en Rooster. Op Matches: titel Matches, Geen uitnodigingen, geen knop Nieuwe match. |
| AT-11 | web | ok | Cursor-agent | Bevestiging Team verlaten?, daarna overzicht zonder Team Alpha. Snackbar: Je hebt "Team Alpha" verlaten. |
| AT-13 | web | ok | Cursor-agent | pedroB via API opnieuw in team 315. Als pedroA: lid-icoon bij pedroB, dialoog Lid verwijderen?, daarna Leden (1) alleen pedroA. Snackbar: pedroB is uit het team verwijderd. Opnieuw inloggen als pedroB: Je zit nog in geen enkel team. |
| AT-10 | API | ok (bevinding API) | Cursor-agent | Ingelogd als pedroB (geen lid meer). GET /teams/315 gaf 200 met de volledige teamdata, inclusief members. Zie details hieronder. Dit is geen app-fout. |
| AT-04 | Android | ok | Cursor-agent | Inloggen als pedroA. Daarna Mijn teams met Team Alpha, Team Beta en later het nieuwe team. |
| AT-06 | Android | ok | Cursor-agent | `adb shell am force-stop` op het app-pakket, daarna `am start` van MainActivity. Geen inlogscherm. Mijn teams met Team Alpha en Team Beta. |
| AT-08 | Android | ok | Cursor-agent | Team R2t034837 aangemaakt (beschrijving testronde2). Stond daarna in de lijst. |
| AT-12 | Android | ok | Cursor-agent | Op R2t034837 als beheerder: badge Je bent beheerder, knoppen Rooster, Event aanmaken, QR-uitnodiging, Team verwijderen. Geen knop Team verlaten. Leden (1) pedroA Beheerder. |
| AT-20 | Android | ok | Cursor-agent | Event AT20r2 aangemaakt. Datumkiezer is een maandkalender (Begindatum, dagen, Cancel/OK). Tijdkiezer is een analoge klok (Begintijd, AM/PM, Cancel/OK). Snackbar: Event "AT20r2" aangemaakt. |
| AT-26 | Android | ok | Cursor-agent | Route opent Google Maps (`com.google.android.apps.maps`), geen browser. Pin WindesheimAlmere op 52.516800, 5.471400, knop Directions. |
| AT-17 | Android | ok | Cursor-agent | Camera geweigerd (Don't allow). Scherm: Camera niet beschikbaar, uitleg over toestemming, knop Instellingen. Geen crash. |
| (nieuw, NFR-01, agenda Android) | Android | ok | Cursor-agent | Agenda toont dezelfde soort items als op web: verstest, wedstr één keer met Team Alpha, Team Beta en status Geaccepteerd, plus AT20r2 bij R2t034837. Verleden onder Geweest. |
| AT-28 | web / Android | ok | Cursor-agent | Werkt op beide. Verschillen staan in de lijst hieronder. |
| AT-07 | nvt | nvt | nvt | Met de hand niet geforceerd. Blijft nvt, zoals in het instructiebestand. |
| AT-29, AT-30 | nvt | nvt | nvt | Volgens het instructiebestand al in ronde 1 gedaan. Deze ronde niet opnieuw uitgevoerd. |

## Stap 14: scanner of API-addUser

Beide geprobeerd, in deze volgorde.

1. Scanner: knop QR-code scannen in het teamoverzicht als pedroB. Het scherm QR-code scannen opende. De camera gaf een live beeld (webcam). Scannen tot lid worden is niet gelukt, omdat er geen QR-code van stap 13 voor de lens was.
2. API-addUser: daarna pedroB toegevoegd aan team 315.

Eerste API-poging met het token van pedroB: `POST /teams/315/addUser` body `{"userId":104}` gaf 403, error `["You are not authorized to add users to this team"]`. Tweede poging met het token van pedroA (beheerder): 200, message User added to the team successfully, members pedroA (103) en pedroB (104). Daarna verscheen Team Alpha in het overzicht van pedroB.

Gevolg: de app-scanflow die de ingelogde gebruiker zichzelf laat toevoegen, zou tegen deze API dezelfde 403 krijgen. Dat is niet met een geslaagde scan bevestigd. Het is wel het antwoord van de server op dezelfde aanroep.

## AT-10: wat `data` bevatte (privacy)

`POST /auth/login` als pedroB: 200, id 104, token ontvangen (niet in dit rapport). pedroB was op dat moment geen lid van team 315 (net verwijderd in AT-13).

`GET /teams/315` met dat token: 200, `message` Success, `error` null.

Velden in `data`:

- `id`: 315
- `name`: Team Alpha
- `description`: Zaterdagcompetitie
- `ownerId`: 103
- `members`: lijst met één item `{ "id": 103, "name": "pedroA" }`
- `metadata`: leeg object
- `createdAt` / `updatedAt`: ISO-tijdstempels

De server geeft de volledige inhoud, inclusief de ledenlijst, aan een niet-lid met een geldig token. De app toont dat team niet in het overzicht van pedroB. Dat is een bevinding over de API, geen fout in de app.

## AT-28: platformverschillen die ik zelf zag

- Thema: web is donker, Android is licht.
- Navigatie Teams/Agenda: web heeft een rail links, Android heeft een balk onderin.
- Datumkiezer event (Android): Material-kalender met maandgrid, titel Begindatum, knoppen Cancel en OK. Op web in deze ronde niet opnieuw geopend.
- Tijdkiezer event (Android): analoge klok, digitale uren/minuten, AM/PM, titel Begintijd, knoppen Cancel en OK. Op web in deze ronde niet opnieuw geopend.
- Route: op Android opent Google Maps als app. Op web (Pedro, stap 12) opent een browser-tabblad met een kaart.
- Camera bij scannen: op web een echte webcamfeed. Op de emulator bij toestemming een gekleurd tespatroon. Bij weigeren op Android uitleg plus knop Instellingen. Op web doet die instellingenknop volgens de code niets (`kIsWeb`).
- Toetsenbord: op Android schuift het systeemtoetsenbord over het inlogformulier. Op web niet.
- Lay-out web: bij een smal venster blijven de knoppen hetzelfde, de rail blijft zichtbaar.
- Overig dat hetzelfde was: Nederlandse teksten, knoppen op teamdetail (beheerder versus lid), snackbars, match één keer in de agenda met beide teamnamen.

## Blokkades

- Browser-MCP: `browser_tabs` maakte een tab, daarna meldde `browser_navigate` dat er geen tab was. Webtest via CDP op localhost:9160.
- QR-scan tot lid worden op web: geen fysieke QR van stap 13. Uitkomst AT-16 `nvt`.
- `POST /teams/315/addUser` als pedroB: 403. Toevoegen kon alleen met het token van pedroA.
- Eerste Android-inlogpoging faalde omdat `adb input tap` de knop Inloggen miste nadat de foutbanner de layout verschoof, en omdat `input text` de eerste keer 8 tekens in het wachtwoord zette in plaats van 9. Daarna met de echte knopcoördinaten wel ingelogd. Geen app-fout.
- Geen tweede emulator gestart. `emulator-5554` was al `device`. App installeerde. `sys.boot_completed` was 1, package-service found.

## Wat verder opviel

- Na herladen van de webapp bleef pedroB ingelogd (sessie op web).
- Nieuw team R2t034837 staat nog op de server onder pedroA. Niet opgeruimd.
- pedroB is aan het einde van deze ronde geen lid van Team Alpha.
