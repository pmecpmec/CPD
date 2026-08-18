# Rapport laatste klusjes

Branch: `fix/webtitel`, afgesplitst van `main` op `c611cdb` (merge van PR 15, roosterfilter).
Datum: 18 augustus 2026.

## 1. Wat is gewijzigd

Alleen `web/index.html` en `web/manifest.json`. Geen kleuren, iconen of `base href`.

Omschrijving (beide bestanden, dezelfde zin):

Teamplanner is een app om teams, evenementen en wedstrijden te plannen.

In `web/index.html`:
- `meta name="description"`: die zin
- `apple-mobile-web-app-title`: Teamplanner
- `<title>`: Teamplanner

In `web/manifest.json`:
- `name` en `short_name`: Teamplanner
- `description`: dezelfde zin

Regeleinden van die twee bestanden zijn niet omgegooid. Ze stonden al op CRLF in git. `core.autocrlf` is false.

## 2. flutter analyze

Geen issues. Gedraaid na de HTML-wijziging.

```
$ flutter analyze
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
No issues found! (ran in 3.4s)
```

## 3. flutter test

155 tests, allemaal groen. Zelfde aantal als op main na het roosterfilter.

De omgeleide dump beschadigde é, ó en ö. Die drie tekens zijn teruggezet naar de vorm uit de directe `flutter test`-uitvoer.

```
$ flutter test
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
00:00 +17: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: Username already taken
00:00 +18: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: Invalid username or password
00:00 +19: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: Team not found
00:00 +20: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: Invalid or expired token
00:00 +21: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/errors_test.dart: onbekende melding blijft onvertaald
00:00 +22: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents haalt de events van alle teams van de gebruiker op
00:00 +23: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents geeft een lege lijst terug wanneer er niets gepland is
00:00 +24: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents geeft een lege lijst terug bij een onverwacht antwoord
00:00 +25: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvent leest één event op id
00:00 +26: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvent meldt het wanneer het event niet bestaat
00:00 +27: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent verstuurt titel, tijden in UTC en een coördinatenpaar
00:00 +28: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent laat de locatie weg wanneer die niet is opgegeven
00:00 +29: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent geeft een GeenRechtenException als een lid geen event mag maken
00:00 +30: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: wijzigEvent en verwijderEvent stuurt een PUT naar het event zonder teamId mee te sturen
00:00 +31: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: wijzigEvent en verwijderEvent stuurt een DELETE naar het event
00:00 +32: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf pending accepteren en afwijzen
00:00 +33: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf accepted alleen annuleren
00:00 +34: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf declined en canceled niets
00:01 +35: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches haalt de lijst op, inclusief matches van andere teams
00:01 +36: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches geeft een lege lijst terug wanneer er niets is
00:01 +37: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches geeft een lege lijst terug bij een onverwacht antwoord
00:01 +38: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatch leest één match op id
00:01 +39: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatch meldt het wanneer de match niet bestaat
00:01 +40: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: maakMatch verstuurt titel, tijden in UTC en uitnodigingen
00:01 +41: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: maakMatch geeft een GeenRechtenException als een lid geen match mag maken
00:01 +42: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: beantwoordUitnodiging accepteert een uitnodiging
00:01 +43: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: beantwoordUitnodiging wijst een uitnodiging af
00:01 +44: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: User leest id en naam uit het inlogantwoord
00:01 +45: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leest alle velden, met de leden onder de sleutel members
00:01 +46: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leidt de rol af uit ownerId, want de leden hebben er geen
00:01 +47: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team houdt null in description en metadata leeg
00:01 +48: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team laat ownerId leeg als de API het weglaat
00:01 +49: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest titel, tijden, locatie en team
00:01 +50: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest de tijden als UTC en zet ze om naar lokale tijd
00:01 +51: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event stuurt de tijden als UTC terug naar de API
00:01 +52: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event laat de locatie leeg wanneer die ontbreekt
00:01 +53: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match legt het organiserende team vast in teamId en team
00:01 +54: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match houdt de status per uitnodiging bij, niet op de match zelf
00:01 +55: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match noemt alle betrokken teams, organisator eerst
00:01 +56: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match als geaccepteerd als elke uitnodiging dat is
00:01 +57: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match met een afwijzing niet als geaccepteerd
00:01 +58: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match een match zonder uitnodigingen geldt niet als geaccepteerd
00:01 +59: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest de vorm uit GET /matches/invites, met invite-id
00:01 +60: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest het antwoord op een geaccepteerde uitnodiging
00:01 +61: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite valt terug op pending bij een onbekende status
00:01 +62: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: GeoLocatie leest coördinaten, ook een hele graad zonder decimalen
00:01 +63: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: dezelfde match via twee teams wordt één item met beide namen
00:01 +64: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: twee verschillende matches blijven twee items
00:01 +65: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: events worden niet samengevoegd, ook niet bij hetzelfde id
00:01 +66: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: ongeldige code gaat niet naar de repository
00:01 +67: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: voegt de huidige gebruiker toe na een geldige code
00:01 +68: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: meldt het wanneer de gebruiker al lid is, zonder addUser
00:01 +69: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: tweede code tijdens verwerking is geen ongeldige code
00:01 +70: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: meldt het wanneer het team niet bestaat
00:01 +71: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: zonder selectie komen alle items terug
00:01 +72: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: met één gekozen team komen alleen de items van dat team terug
00:01 +73: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: met twee gekozen teams komen de items van beide terug
00:01 +74: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: match via twee teams blijft zichtbaar bij één gekozen team, één keer
00:01 +75: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: isLeegDoorFilter is waar bij selectie zonder resultaat, onwaar bij lege agenda
00:01 +76: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: wis maakt de teamselectie leeg
00:01 +77: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: eigenTeams is gesorteerd op naam en laad wist het filter niet
00:01 +78: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: laad haalt team-ids die niet meer in eigenTeams zitten uit de selectie
00:01 +79: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: vanEvent vult teamIds uit Event.teamId
00:02 +80: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl gebruikt op Android het geo-schema met een pin op de locatie
00:02 +81: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl zet een leesbare plaatsnaam als label bij de pin
00:02 +82: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl laat het label weg wanneer er geen plaatsnaam bekend is
00:02 +83: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl opent op web een Google Maps-route over https
00:02 +84: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl houdt negatieve coördinaten heel op beide platformen
00:02 +85: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl loopt niet stuk op de nulmeridiaan
00:02 +86: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform kiest het geo-schema op een Android-toestel
00:02 +87: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform valt op andere platformen terug op de web-URL
00:02 +88: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute opent de URL die bij het gekozen platform hoort
00:02 +89: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute meldt het wanneer er niets op de URL reageert
00:02 +90: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute valt niet om als er op Android geen kaart-app staat
00:02 +91: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet een leeg rooster in twee lege delen
00:02 +92: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet afgelopen items in het verleden en de rest in de toekomst
00:02 +93: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert de toekomst op begintijd, vroegste eerst
00:02 +94: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert het verleden op begintijd, meest recent eerst
00:02 +95: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert bij gelijke begintijd op titel
00:02 +96: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet een item dat precies nu eindigt bij de toekomst
00:02 +97: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: matchStatusLabel vertaalt pending, accepted en declined naar Nederlandse labels
00:02 +98: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: matchStatusLabel toont voor de organisator of iedereen heeft geaccepteerd
00:02 +99: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: RoosterItem.vanEvent en vanMatch neemt de teamnaam uit het ingebedde team van het event
00:02 +100: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: RoosterItem.vanEvent en vanMatch zet bij een match de status en de betrokken teamnamen
00:02 +101: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/teams_controller_test.dart: wis maakt de lijst en de foutmelding leeg
00:02 +102: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/teams_controller_test.dart: wis wist ook een eerdere foutmelding
00:02 +103: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode heeft de afgesproken vorm en bevat het team-id
00:02 +104: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode begint met het voorvoegsel en eindigt op het team-id
00:02 +105: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode geeft elk team een eigen code
00:02 +106: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode een gebouwde code is weer terug te lezen
00:02 +107: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId leest een geldige code
00:02 +108: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId wijst drie ongeldige codes af
00:02 +109: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId wijst nul, negatief en ontbrekend af
00:02 +110: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_detail_screen_test.dart: toont titel, team, tijd, locatie en omschrijving
00:03 +111: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:03 +112: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:03 +113: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:03 +114: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:03 +115: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:03 +116: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:04 +117: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/home_shell_test.dart: NavigationBar laadt de agenda opnieuw bij openen van het tabblad
00:04 +118: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/login_screen_test.dart: toont de invoervelden en de inlogknop
00:04 +119: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/login_screen_test.dart: toont de invoervelden en de inlogknop
00:04 +120: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/login_screen_test.dart: toont de invoervelden en de inlogknop
00:04 +121: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/match_invites_screen_test.dart: biedt bij pending accepteren en afwijzen
00:05 +122: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/match_invites_screen_test.dart: biedt bij pending accepteren en afwijzen
00:05 +123: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:05 +124: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:05 +125: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:05 +126: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:05 +127: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:05 +128: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:05 +129: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:05 +130: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:05 +131: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:05 +132: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:05 +133: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:05 +134: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:05 +135: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:06 +136: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:06 +137: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:06 +138: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:06 +139: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:06 +140: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:06 +141: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:06 +142: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:06 +143: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:06 +144: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: rollen (FR-07, FR-08) de beheerder ziet de beheerknoppen en geen "Team verlaten"
00:06 +145: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:06 +146: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:07 +147: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:07 +148: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: privacy (FR-06) een niet-lid ziet alleen naam en omschrijving
00:07 +149: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:07 +150: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:07 +151: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:07 +152: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert een lid na bevestiging
00:07 +153: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert het team na bevestiging
00:07 +154: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: een mislukte ophaalpoging toont de melding uit errors.dart
00:07 +155: All tests passed!
```

## 4. flutter build web --release

Geslaagd. Exitcode 0. Uitvoer eindigt op Built build\web.

```
$ flutter build web --release
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
Compiling lib\main.dart for the Web...
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Font asset "CupertinoIcons.ttf" was tree-shaken, reducing it from 257628 to 1472 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 12476 bytes (99.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib\main.dart for the Web...                             67.6s
√ Built build\web
```

## 5. git status na de HTML-wijziging (voor commit)

Alleen de twee web-bestanden bewust gewijzigd. De untracked bestanden hoorden bij eerdere taken. Die zijn niet meegenomen.

```
On branch fix/webtitel
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   web/index.html
	modified:   web/manifest.json

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	docs/rapport-opruimen.md
	docs/sdd-screenshots/android-05-match-aanmaken.png
	docs/sdd-screenshots/android-06-match-uitnodigingen.png

no changes added to commit (use "git add" and/or "git commit -a")
```

Geen tientallen CRLF-bestanden.

## 6. Klus 2: mappen verwijderen (buiten git)

Niet gecommit. Map `oplevering` niet aangeraakt.

Commando:

```
Remove-Item -Recurse -Force C:\Users\pmec\Documents\School\CPD\worktrees
Remove-Item -Recurse -Force C:\Users\pmec\Documents\School\CPD\_t08-parkeren
```

Exitcode 0. Geen fout over bestand in gebruik.

Test-Path:

```
worktrees: False
_t08-parkeren: False
```

Beide paden bestaan niet meer.

## 7. Pull request

PR-URL: https://github.com/pmecpmec/CPD/pull/16
Gemerged: nee op het moment van dit rapport. Merge volgt alleen als de pipeline groen is.
