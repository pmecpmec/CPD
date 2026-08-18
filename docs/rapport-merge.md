# Rapport merge naar main

Datum: 18 augustus 2026.
Branch: `dev`, daarna PR naar `main`.

## Mergevolgorde

Vier `--no-ff` merges op `dev`, in deze volgorde:

1. `origin/feature/T-08-T-09-roosters` (PR #9). Geen conflicten.
2. `origin/feature/T-05-T-10` (PR #12). Drie conflicten. Zie hieronder.
3. `origin/fix/acceptatietest-bevindingen` (PR #11). Geen git-conflicten. Analyze faalde daarna op een testdubbel. Zie hieronder.
4. `origin/docs/oplevering-bewijs` (PR #10). Conflict in `docs/platformverschillen.md`.

Daarna op `dev`: commit `fix: testdubbel MatchRepository na merge T-05/T-10` en commit `fix: tweede scan tijdens verwerking geen ongeldige-code-melding`.

## Conflicten

### match_repository.dart (add/add bij merge 2)

T-08/T-09 had de leeskant: `haalMatches` en `haalMatch`.
T-05/T-10 had het bestand opnieuw, met lezen plus schrijven: `maakMatch`, `haalOntvangenUitnodigingen`, `beantwoordUitnodiging`.

Behouden: beide. Interface en `ApiMatchRepository` hebben nu alle vijf methoden. Commentaar van beide kanten samengevoegd. Geen dubbele methodenamen.

### match_repository_test.dart (add/add bij merge 2)

T-08/T-09: tests voor `haalMatches` en `haalMatch`.
T-05/T-10: tests voor `maakMatch` en `beantwoordUitnodiging`.

Behouden: beide groepen. Helper `matchJson` gecombineerd (status, invites, team, metadata).

### teams_screen.dart (content bij merge 2)

T-08/T-09: `wis()` op de uitlogknop plus import van `MyScheduleController`.
T-05/T-10: scanknop, `_scanQr`, imports voor QR en matches.

Behouden: allebei. Uitloggen wist teams en agenda. FAB voor QR-scan blijft staan.

### main.dart

Git mergete dit automatisch. T-08/T-09 voegde `MyScheduleController` en `HomeShell` toe. T-05/T-10 voegde geen extra globale providers toe. QR- en matchcontrollers ontstaan bij het openen van het scherm. Beide repositories (`EventRepository`, `MatchRepository`) stonden er al in.

### platformverschillen.md (add/add bij merge 4)

T-05/T-10: tabel camera/toestemming web versus Android.
Docs-bewijs: wat op 17 augustus is gezien (opstart, thema, navigatie, sessie).

Behouden: beide teksten, in twee secties.

### Testdubbel na merge 3 (geen git-conflict)

`home_shell_test.dart` kwam uit de acceptatietak. `_NepMatchRepository` implementeerde alleen de leeskant. Na merge 2 eist de interface ook schrijfmethoden. Analyze: Missing concrete implementations.

Opgelost: `maakMatch`, `haalOntvangenUitnodigingen` en `beantwoordUitnodiging` toegevoegd, net als in `match_invites_screen_test.dart`. Geen nieuwe features.

## QrScanBezig

In `qr_scan_controller.dart` gaf een tweede `verwerkCode` tijdens `_bezig` `QrScanOngeldigeCode` terug. De camera vuurt dezelfde code tientallen keren per seconde.

Toegevoegd: `QrScanBezig`. Het scherm negeert die stilzwijgend. Geen snackbar "code klopt niet". Test: tweede code tijdens lopende verwerking levert `QrScanBezig`, geen `QrScanOngeldigeCode`.

## Tests

Exact aantal: **143**. Allemaal geslaagd.

## dart format lib test

```
Formatted 62 files (0 changed) in 0.38 seconds.
```

## flutter analyze

```
Resolving dependencies...
Downloading packages...
  hooks 2.0.2 (2.1.0 available)
  matcher 0.12.19 (0.12.20 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.0 (1.19.0 available)
  permission_handler 12.0.3 (13.0.1 available)
  permission_handler_android 13.0.1 (14.0.0 available)
  qr 3.0.2 (4.0.0 available)
  record_use 0.6.0 (1.1.0 available)
  test_api 0.7.11 (0.7.13 available)
  vector_math 2.2.0 (2.4.2 available)
Got dependencies!
10 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing crossplatformdevelopment...
No issues found! (ran in 9.8s)
```

## flutter test

```
Resolving dependencies...
Downloading packages...
  hooks 2.0.2 (2.1.0 available)
  matcher 0.12.19 (0.12.20 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.0 (1.19.0 available)
  permission_handler 12.0.3 (13.0.1 available)
  permission_handler_android 13.0.1 (14.0.0 available)
  qr 3.0.2 (4.0.0 available)
  record_use 0.6.0 (1.1.0 available)
  test_api 0.7.11 (0.7.13 available)
  vector_math 2.2.0 (2.4.2 available)
Got dependencies!
10 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart
00:00 +0: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: pakt het data-veld uit de envelop
00:00 +1: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: geeft een lijst uit de envelop als lijst terug
00:00 +2: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: laat een antwoord zonder envelop ongemoeid
00:00 +3: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: meldt een verlopen sessie alleen wanneer er een token meeging
00:00 +4: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: geeft de foutmelding uit het error-veld door aan de gebruiker
00:00 +5: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: zet meerdere meldingen elk op een eigen regel
00:00 +6: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: leest ook een losse tekst en het veld errors
00:00 +7: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: valt terug op een algemene melding zonder bruikbaar foutveld
00:00 +8: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: gebruikt message als er geen foutveld is
00:00 +9: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/api_client_test.dart: vertaalt 403 en 404 naar de bijbehorende fouten
00:00 +10: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: login bewaart het token en het gebruikers-id bij een geslaagde poging
00:00 +11: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: login geeft een duidelijke fout bij verkeerde inloggegevens
00:00 +12: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: login meldt het wanneer de server geen token teruggeeft
00:00 +13: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: sessie stuurt het token mee in de Authorization-header
00:00 +14: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: sessie logout wist de bewaarde sessie
00:00 +15: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: foutafhandeling vertaalt een serverfout naar een leesbare melding
00:00 +16: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: foutafhandeling neemt de melding uit het error-veld over
00:01 +17: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: Username already taken
00:01 +18: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: Invalid username or password
00:01 +19: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: Team not found
00:01 +20: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: Invalid or expired token
00:01 +21: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: onbekende melding blijft onvertaald
00:01 +22: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents haalt de events van alle teams van de gebruiker op
00:01 +23: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents geeft een lege lijst terug wanneer er niets gepland is
00:01 +24: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents geeft een lege lijst terug bij een onverwacht antwoord
00:01 +25: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvent leest een event op id
00:01 +26: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvent meldt het wanneer het event niet bestaat
00:01 +27: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent verstuurt titel, tijden in UTC en een coördinatenpaar
00:01 +28: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent laat de locatie weg wanneer die niet is opgegeven
00:01 +29: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent geeft een GeenRechtenException als een lid geen event mag maken
00:01 +30: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: wijzigEvent en verwijderEvent stuurt een PUT naar het event zonder teamId mee te sturen
00:01 +31: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: wijzigEvent en verwijderEvent stuurt een DELETE naar het event
00:02 +32: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf pending accepteren en afwijzen
00:02 +33: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf accepted alleen annuleren
00:02 +34: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf declined en canceled niets
00:02 +35: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches haalt de lijst op, inclusief matches van andere teams
00:02 +36: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches geeft een lege lijst terug wanneer er niets is
00:02 +37: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches geeft een lege lijst terug bij een onverwacht antwoord
00:02 +38: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatch leest een match op id
00:02 +39: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatch meldt het wanneer de match niet bestaat
00:02 +40: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: maakMatch verstuurt titel, tijden in UTC en uitnodigingen
00:02 +41: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: maakMatch geeft een GeenRechtenException als een lid geen match mag maken
00:02 +42: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: beantwoordUitnodiging accepteert een uitnodiging
00:02 +43: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: beantwoordUitnodiging wijst een uitnodiging af
00:03 +44: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: User leest id en naam uit het inlogantwoord
00:03 +45: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leest alle velden, met de leden onder de sleutel members
00:03 +46: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leidt de rol af uit ownerId, want de leden hebben er geen
00:03 +47: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team houdt null in description en metadata leeg
00:03 +48: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team laat ownerId leeg als de API het weglaat
00:03 +49: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest titel, tijden, locatie en team
00:03 +50: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest de tijden als UTC en zet ze om naar lokale tijd
00:03 +51: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event stuurt de tijden als UTC terug naar de API
00:03 +52: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event laat de locatie leeg wanneer die ontbreekt
00:03 +53: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match legt het organiserende team vast in teamId en team
00:03 +54: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match houdt de status per uitnodiging bij, niet op de match zelf
00:03 +55: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match noemt alle betrokken teams, organisator eerst
00:03 +56: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match als geaccepteerd als elke uitnodiging dat is
00:03 +57: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match met een afwijzing niet als geaccepteerd
00:03 +58: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match een match zonder uitnodigingen geldt niet als geaccepteerd
00:03 +59: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest de vorm uit GET /matches/invites, met invite-id
00:03 +60: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest het antwoord op een geaccepteerde uitnodiging
00:03 +61: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite valt terug op pending bij een onbekende status
00:03 +62: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: GeoLocatie leest coördinaten, ook een hele graad zonder decimalen
00:03 +63: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: dezelfde match via twee teams wordt een item met beide namen
00:03 +64: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: twee verschillende matches blijven twee items
00:03 +65: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: events worden niet samengevoegd, ook niet bij hetzelfde id
00:04 +66: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: ongeldige code gaat niet naar de repository
00:04 +67: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: voegt de huidige gebruiker toe na een geldige code
00:04 +68: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: meldt het wanneer de gebruiker al lid is, zonder addUser
00:04 +69: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: tweede code tijdens verwerking is geen ongeldige code
00:04 +70: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: meldt het wanneer het team niet bestaat
00:04 +71: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl gebruikt op Android het geo-schema met een pin op de locatie
00:05 +72: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl zet een leesbare plaatsnaam als label bij de pin
00:05 +73: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl laat het label weg wanneer er geen plaatsnaam bekend is
00:05 +74: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl opent op web een Google Maps-route over https
00:05 +75: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl houdt negatieve coördinaten heel op beide platformen
00:05 +76: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl loopt niet stuk op de nulmeridiaan
00:05 +77: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform kiest het geo-schema op een Android-toestel
00:05 +78: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform valt op andere platformen terug op de web-URL
00:05 +79: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute opent de URL die bij het gekozen platform hoort
00:05 +80: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute meldt het wanneer er niets op de URL reageert
00:05 +81: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute valt niet om als er op Android geen kaart-app staat
00:05 +82: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet een leeg rooster in twee lege delen
00:05 +83: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet afgelopen items in het verleden en de rest in de toekomst
00:05 +84: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert de toekomst op begintijd, vroegste eerst
00:05 +85: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert het verleden op begintijd, meest recent eerst
00:05 +86: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert bij gelijke begintijd op titel
00:05 +87: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet een item dat precies nu eindigt bij de toekomst
00:05 +88: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: matchStatusLabel vertaalt pending, accepted en declined naar Nederlandse labels
00:05 +89: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: matchStatusLabel toont voor de organisator of iedereen heeft geaccepteerd
00:05 +90: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: RoosterItem.vanEvent en vanMatch neemt de teamnaam uit het ingebedde team van het event
00:05 +91: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: RoosterItem.vanEvent en vanMatch zet bij een match de status en de betrokken teamnamen
00:05 +92: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/teams_controller_test.dart: wis maakt de lijst en de foutmelding leeg
00:05 +93: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/teams_controller_test.dart: wis wist ook een eerdere foutmelding
00:06 +94: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode heeft de afgesproken vorm en bevat het team-id
00:06 +95: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode begint met het voorvoegsel en eindigt op het team-id
00:06 +96: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode geeft elk team een eigen code
00:06 +97: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode een gebouwde code is weer terug te lezen
00:06 +98: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId leest een geldige code
00:06 +99: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId wijst drie ongeldige codes af
00:06 +100: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId wijst nul, negatief en ontbrekend af
00:06 +101: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_detail_screen_test.dart: toont titel, team, tijd, locatie en omschrijving
00:08 +102: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie voor verzending (FR-11) een lege titel wordt geweigerd
00:09 +103: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie voor verzending (FR-11) een lege titel wordt geweigerd
00:09 +104: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie voor verzending (FR-11) een lege titel wordt geweigerd
00:10 +105: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie voor verzending (FR-11) een lege titel wordt geweigerd
00:10 +106: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie voor verzending (FR-11) een lege titel wordt geweigerd
00:10 +107: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie voor verzending (FR-11) een lege titel wordt geweigerd
00:11 +108: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie voor verzending (FR-11) een lege titel wordt geweigerd
00:11 +109: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/login_screen_test.dart: toont de invoervelden en de inlogknop
00:11 +110: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/match_invites_screen_test.dart: biedt bij pending accepteren en afwijzen
00:12 +111: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/match_invites_screen_test.dart: biedt bij pending accepteren en afwijzen
00:12 +112: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:12 +113: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:12 +114: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:12 +115: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:12 +116: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:13 +117: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:13 +118: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:13 +119: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:13 +120: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:13 +121: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:14 +122: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:14 +123: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:14 +124: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:14 +125: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:15 +126: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:15 +127: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:16 +128: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:16 +129: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:17 +130: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:17 +131: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:17 +132: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:17 +133: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:17 +134: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:17 +135: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:17 +136: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden toont de melding uit errors.dart als de server weigert
00:18 +137: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden toont de melding uit errors.dart als de server weigert
00:18 +138: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:19 +139: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:19 +140: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert een lid na bevestiging
00:20 +141: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert het team na bevestiging
00:20 +142: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: een mislukte ophaalpoging toont de melding uit errors.dart
00:21 +143: All tests passed!
```

## Android

App draaide: **ja**, op emulator `cpd_test` / `emulator-5554`.

Eerste `flutter run` faalde met `Can't find service: package`. `sys.boot_completed` was 1, maar `service check package` gaf not found. `system_server` draaide niet. Emulator gestopt en opnieuw gestart zonder snapshot. Daarna waren package- en activity-service aanwezig. `adb uninstall com.example.crossplatformdevelopment` slaagde. Tweede `flutter run -d emulator-5554` installeerde de APK en toonde `Flutter run key commands`.

Handmatig, via de UI van de emulator:

1. Inloggen met `hr17014445` / `geheim123`. Eerste poging faalde omdat adb een extra letter in de velden zette. Na corrigeren: scherm Mijn teams, team Herstelteam.
2. Team Herstelteam geopend. Detail toonde titel, Testdesc, "Je bent beheerder", Leden (1), Rooster, Event aanmaken, QR-uitnodiging, Team verwijderen.
3. QR-scanscherm geopend via de knop "QR-code scannen". Systeemdialoog: "Allow crossplatformdevelopment to take pictures and record video?" met While using the app, Only this time, Don't allow. Camera zelf niet verder getest.

Web in deze ronde: niet gedraaid.

## Pipeline

Na merge van PR #13 naar `main`. Push-run van 18 augustus 2026.

### CI (run 32087914670): groen

| Job | Resultaat |
|---|---|
| Analyse en test | groen, 1m26s. Formattering, analyse en tests. |
| Androidbuild | groen, 9m27s. `flutter build apk --release`. |
| Webbuild | groen, 1m36s. `flutter build web --release`. |

Waarschuwingen (geen falen): Node.js 20 deprecated op checkout. setup-java v4 deprecated op Androidbuild.

### Deploy (run 32087914553): rood, bekend

| Job | Resultaat |
|---|---|
| Webversie bouwen | rood. `flutter build web` slaagde. `actions/configure-pages@v5` faalt: Get Pages site failed, repository heeft Pages niet zo gezet. |
| Publiceren | overgeslagen |

Foutmelding: `HttpError: Not Found` op `https://docs.github.com/rest/pages/pages#get-a-apiname-pages-site`.
