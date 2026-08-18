# Rapport bewijs screenshots

Datum: 17 augustus 2026.
Branch: `docs/oplevering-bewijs`.
App gedraaid vanuit worktree `screenshot-roosters` op commit `e76ee38` (T-08 en T-09).
Geen wijzigingen in `lib/` of `test/`.

Accounts via de API: beheerder `bewijs12537a`, lid `bewijs12537b`, leeg account `bewijs12537c`.
Teams: Bewijs Alpha 12537 (id 313) en Bewijs Beta 12537 (id 314).
Events: Training geweest (verleden) en Wedstrijd komt eraan (toekomst).

Screenshotmap: `C:\Users\pmec\Documents\School\CPD\oplevering\SDD\screenshots\`
Die map ligt buiten de Flutter-repo.

## Web (Chrome)

| Bestand | Gelukt | Toelichting |
|---|---|---|
| web-01-inloggen.png | ja | Leeg inlogscherm, Teamplanner |
| web-02-inloggen-fout.png | ja | Verkeerd wachtwoord, melding Gebruikersnaam of wachtwoord klopt niet |
| web-03-teams-leeg.png | ja | Account c, tekst Je zit nog in geen enkel team |
| web-04-teams-gevuld.png | ja | Beheerder, twee teams Alpha en Beta |
| web-05-teamdetail-beheerder.png | ja | QR-uitnodiging, Event aanmaken, Team verwijderen |
| web-06-teamdetail-lid.png | ja | Zelfde team Alpha als lid, knop Team verlaten, geen QR of Event aanmaken |
| web-07-qr-uitnodiging.png | ja | Dialoog met QR-code, tekst teamplanner:team:313 |
| web-08-event-formulier.png | ja | Validatiefout Vul een titel in. onder het titelveld |
| web-09-eventdetail.png | ja | Wedstrijd komt eraan, knop Route |
| web-10-teamrooster.png | ja | Koppen Komt eraan en Geweest |
| web-11-persoonlijk-rooster.png | ja | Agenda-tab, teamnaam Bewijs Alpha 12537 bij elk item |
| web-12-navigatie-breed.png | ja | NavigationRail links. Zelfde moment als web-04 |
| web-13-navigatie-smal.png | ja | Venster 390 pixels breed, NavigationBar onderaan |

Geen web-screenshot overgeslagen.

## Android (emulator-5554)

| Bestand | Gelukt | Toelichting |
|---|---|---|
| android-01-inloggen.png | ja | Na uitloggen, licht thema |
| android-02-teams.png | ja | Twee teams, NavigationBar onderaan |
| android-03-teamdetail.png | ja | Beheerder van Alpha, Rooster, Event aanmaken, QR, Verwijderen |
| android-04-persoonlijk-rooster.png | ja | Agenda-tab, teamnaam bij elk item |

Geen Android-screenshot overgeslagen.

## Niet gedaan in deze ronde

- Camera en QR-scan op een toestel.
- Indrukken van de knop Route.
- Openen van de datum- of tijdkiezer.
- Handmatig controleren of de web-sessie na herladen blijft staan. Op Android bleef een oude sessie (Herstelteam) staan tot er werd uitgelogd.

## Documenten

- `docs/platformverschillen.md`: nieuw, alleen gezien verschil plus het camerapunt uit de specificatie.
- `docs/rapport-bewijs.md`: dit bestand.
