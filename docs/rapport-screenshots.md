# Rapport screenshots (18 augustus 2026)

Branch: `docs/sdd-screenshots`, afgesplitst van `main`. Geen wijzigingen in `lib/`. Niet gecommit.

## Nieuwe screenshots

Gemaakt op web, Chrome, poort 9140, app uit deze repository. Ingelogd als `hr17014445`.

| Bestand | Inhoud |
|---|---|
| `web-14-match-aanmaken.png` | Formulier Nieuwe match: dropdown Jouw team, titel, omschrijving, tijden, lijst teams met vinkjes |
| `web-15-match-uitnodigingen.png` | Scherm Matches met openstaande uitnodiging "Match screenshots 0818", status In afwachting |
| `web-16-teamrooster-match.png` | Teamrooster Herstelteam, die match met statuschip In afwachting en beide teamnamen |
| `web-17-agenda-ontdubbeld.png` | Agenda: dezelfde match één keer, ondertitel "Herstelteam, Herstelteam B 0818" |

Locatie: `oplevering/SDD/screenshots/` en kopie in `docs/sdd-screenshots/`.

## Ontbrekende shots

Geen gat in web-01 tot web-17 of android-01 tot android-04.

Android-shots van matches zijn overgeslagen. De opdracht vroeg de vier nieuwe shots op web.

## Oude set (web-01 tot web-13, android-01 tot android-04)

Alle bestanden bestaan. Reeks is compleet. Beelden zijn scherp. De bestandsnaam klopt bij wat erop staat.

`web-12-navigatie-breed.png` is inhoudelijk hetzelfde beeld als `web-04-teams-gevuld.png` (teamoverzicht met NavigationRail).

`web-08` toont het eventformulier met een validatiefout op de lege titel. Dat is nog steeds het formulier uit 3.1.

`web-10` is een teamrooster met gewone events, zonder matchstatus. Daarvoor is nu `web-16`.

Geheimen: nergens een token. Op `web-02` staat een gebruikersnaam en een gemaskeerd wachtwoord (punten, oogje dicht). Op de nieuwe shots staat geen wachtwoordveld. De QR-code op `web-07` is `teamplanner:team:313`, dat is een team-id, geen sessietoken.

## Platformverschillen

`docs/platformverschillen.md` is aangevuld met wat deze ronde zichtbaar was. Android is niet opnieuw geopend. De Android-punten komen uit de bestaande android-shots versus web: licht versus donker thema, NavigationBar versus NavigationRail, systeemstatusbalk. Camera en route zijn niet opnieuw gezien.

## Hoe de match-data tot stand kwam

Het formulier Nieuwe match (web-14) is in de app geopend. De lijst uitgenodigde teams is lang (de API geeft alle teams). Scrolling via de automatisering kwam niet verder. Daarna is via de bestaande REST-API een tweede team (`Herstelteam B 0818`) gebruikt dat al via de app-UI was aangemaakt, en is de match `Match screenshots 0818` aangemaakt van Herstelteam naar dat tweede team. Status `pending`. Daarna zijn web-15 tot web-17 in de app gefotografeerd.

De cursor-ide-browser (MCP) kreeg geen werkende tab. Screenshots zijn via Chrome remote debugging (CDP) gemaakt, hetzelfde pad als de oude web-set.

## Vragen voor Pedro

1. Mag het extra team `Herstelteam B 0818` en match `Match screenshots 0818` op de server blijven staan?
2. Moet hoofdstuk 3.1 van het SDD twee rijen krijgen voor match aanmaken en uitnodigingen? Die schermen bestaan in de app, maar staan niet in de tabel.
3. `web-12` is een duplicaat van `web-04`. Wil je die vervangen of zo laten?
4. Wil je later nog Android-shots van de matchschermen?
