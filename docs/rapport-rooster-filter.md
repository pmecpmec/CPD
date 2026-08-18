# Rapport roosterfilter (FR-14 / B-28)

Branch: `feature/rooster-filter`, afgesplitst van `main` op `9878f02`.
Datum: 18 augustus 2026.

## 1. Per taak

| Taak | Status |
|---|---|
| 1. `teamIds` op `RoosterItem`, vullen in `vanEvent`, samenvoegen bij ontdubbelen | gedaan |
| 2. Filter in `MyScheduleController` | gedaan |
| 3. FilterChips op `MyScheduleScreen` | gedaan |
| 4. Unit- en widgettests, analyze schoon, meer dan 143 tests | gedaan (155 tests) |
| 5. Commentaar boven `TeamUitnodiging` | gedaan |
| Screenshot `docs/sdd-screenshots/web-18-agenda-filter.png` | gedaan |
| Rapport | dit bestand |

## 2. flutter analyze en flutter test

Aantal tests voor deze taak: 143.
Aantal tests na: 155. Allemaal groen.

PowerShell heeft de uitvoer van `flutter test` als UTF-16 bewaard. Daarbij raakten de letters é, ó en ö beschadigd (`één` werd `├⌐├⌐n`). Hieronder staat de volledige uitvoer. Waar die tekens in testnamen zitten, is de leesbare vorm tussen haakjes gezet.

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
No issues found! (ran in 1.8s)
```

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
00:01 +32: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf pending accepteren en afwijzen
00:01 +33: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf accepted alleen annuleren
00:01 +34: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/invite_overgangen_test.dart: toegestaneInviteOvergangen biedt vanaf declined en canceled niets
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
00:02 +66: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: ongeldige code gaat niet naar de repository
00:02 +67: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: voegt de huidige gebruiker toe na een geldige code
00:02 +68: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: meldt het wanneer de gebruiker al lid is, zonder addUser
00:02 +69: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: tweede code tijdens verwerking is geen ongeldige code
00:02 +70: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/qr_scan_controller_test.dart: meldt het wanneer het team niet bestaat
00:02 +71: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: zonder selectie komen alle items terug
00:02 +72: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: met één gekozen team komen alleen de items van dat team terug
00:02 +73: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: met twee gekozen teams komen de items van beide terug
00:02 +74: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: match via twee teams blijft zichtbaar bij één gekozen team, één keer
00:02 +75: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: isLeegDoorFilter is waar bij selectie zonder resultaat, onwaar bij lege agenda
00:02 +76: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: wis maakt de teamselectie leeg
00:02 +77: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: eigenTeams is gesorteerd op naam en laad wist het filter niet
00:02 +78: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: laad haalt team-ids die niet meer in eigenTeams zitten uit de selectie
00:02 +79: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/rooster_filter_test.dart: vanEvent vult teamIds uit Event.teamId
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
00:03 +91: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet een leeg rooster in twee lege delen
00:03 +92: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet afgelopen items in het verleden en de rest in de toekomst
00:03 +93: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert de toekomst op begintijd, vroegste eerst
00:03 +94: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert het verleden op begintijd, meest recent eerst
00:03 +95: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert bij gelijke begintijd op titel
00:03 +96: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet een item dat precies nu eindigt bij de toekomst
00:03 +97: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: matchStatusLabel vertaalt pending, accepted en declined naar Nederlandse labels
00:03 +98: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: matchStatusLabel toont voor de organisator of iedereen heeft geaccepteerd
00:03 +99: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: RoosterItem.vanEvent en vanMatch neemt de teamnaam uit het ingebedde team van het event
00:03 +100: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: RoosterItem.vanEvent en vanMatch zet bij een match de status en de betrokken teamnamen
00:03 +101: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/teams_controller_test.dart: wis maakt de lijst en de foutmelding leeg
00:03 +102: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/teams_controller_test.dart: wis wist ook een eerdere foutmelding
00:03 +103: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode heeft de afgesproken vorm en bevat het team-id
00:03 +104: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode begint met het voorvoegsel en eindigt op het team-id
00:03 +105: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode geeft elk team een eigen code
00:03 +106: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode een gebouwde code is weer terug te lezen
00:03 +107: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId leest een geldige code
00:03 +108: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId wijst drie ongeldige codes af
00:03 +109: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.leesTeamId wijst nul, negatief en ontbrekend af
00:03 +110: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_detail_screen_test.dart: toont titel, team, tijd, locatie en omschrijving
00:04 +111: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:04 +112: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:05 +113: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:05 +114: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:05 +115: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:05 +116: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:05 +117: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/home_shell_test.dart: NavigationBar laadt de agenda opnieuw bij openen van het tabblad
00:05 +118: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/login_screen_test.dart: toont de invoervelden en de inlogknop
00:06 +119: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/login_screen_test.dart: toont de invoervelden en de inlogknop
00:06 +120: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/match_invites_screen_test.dart: biedt bij pending accepteren en afwijzen
00:06 +121: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/match_invites_screen_test.dart: biedt bij pending accepteren en afwijzen
00:06 +122: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:06 +123: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:06 +124: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:06 +125: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:06 +126: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/my_schedule_screen_test.dart: toont geen filterchips bij één team
00:07 +127: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:07 +128: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:07 +129: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_invite_dialog_test.dart: toont de code van dit team met de teamnaam erbij
00:07 +130: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:07 +131: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:07 +132: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:07 +133: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:07 +134: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/qr_scan_screen_test.dart: toont een scan-knop naast Nieuw team
00:07 +135: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:07 +136: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:07 +137: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:07 +138: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:08 +139: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:08 +140: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:08 +141: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:08 +142: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:08 +143: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:08 +144: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:09 +145: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:09 +146: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:09 +147: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: AppBar-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:09 +148: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: privacy (FR-06) een niet-lid ziet alleen naam en omschrijving
00:09 +149: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:09 +150: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:09 +151: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: systeem-terug wist de foutmelding zodat die niet op inloggen blijft staan
00:09 +152: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert een lid na bevestiging
00:09 +153: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert het team na bevestiging
00:09 +154: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: een mislukte ophaalpoging toont de melding uit errors.dart
00:10 +155: All tests passed!
```

## 3. git status na de codecommits

Bewust gewijzigd in deze taak, nog niet in de documentatiecommit: `lib/core/config.dart`, dit rapport, de screenshot.

Al aanwezig vóór deze taak, niet aangeraakt:

```
 M docs/sdd-screenshots/OVERZICHT.md
?? docs/rapport-opruimen.md
?? docs/sdd-screenshots/android-05-match-aanmaken.png
?? docs/sdd-screenshots/android-06-match-uitnodigingen.png
```

Geen tientallen bestanden met regeleinde-ruis. `core.autocrlf` is false. Aangeraakte Dart-bestanden staan op LF.

## 4. Keuzes

| Keuze | Alternatief | Reden |
|---|---|---|
| Eigen teams uit `GET /teams`, daarna `Team.isLid` | Alleen team-info uit events | De controller deed dat filteren al. De server geeft alle teams. Dat is dezelfde bron als het teamoverzicht. |
| `teamIds` optioneel met default `const []` | Verplicht veld op de constructor | Bestaande tests bouwen `RoosterItem` zonder ids. Die blijven zo groen. `vanEvent` en de matchregels vullen het wél. |
| Filteren ná ontdubbelen, op de bewaarde `_verdeling` | Filteren vóór ontdubbelen | Staat in de taak. Een match via twee teams houdt beide ids, dus één gekozen team houdt hem zichtbaar. |
| Chips in een `Column` boven `RoosterLijst` | Chips als eerste kind van de lijst | De rij blijft staan bij scrollen. `RoosterLijst` hoefde niet te wijzigen. |
| `vanEvent` vult altijd `Event.teamId` | Alleen vullen als `team` is meegestuurd | `teamId` is een verplicht int-veld op `Event`. De naam kan ontbreken. Filteren heeft het id nodig. |
| Sorteren met `toLowerCase().compareTo` | `Intl` / locale | Eenvoudigste hoofdletterongevoelige vergelijking. Geen extra pakket. |
| `wis()` wist ook `_eigenTeams` | Alleen de selectie legen | Anders blijven chips van de vorige gebruiker even staan tot de volgende `laad()`. |

Als de API bij een match geen ingebed `team` meestuurt, kan `teamNamen` korter zijn dan `teamIds`. Filteren gebruikt de ids.

## 5. Wat ik niet heb gedaan

- Geen rij in `docs/sdd-screenshots/OVERZICHT.md`. Dat bestand had al lokale, niet-gecommitte wijzigingen (android-05 en android-06). Die hoorden niet bij deze taak.
- Geen kopie naar `oplevering/SDD/afbeeldingen/`. Die map ligt buiten deze git-repo. De opdracht vroeg alleen `docs/sdd-screenshots`.
- Filter niet opnieuw op Android geopend. De opdracht vroeg een webshot.
- cursor-ide-browser (MCP) kreeg geen werkende tab (`No browser tab available`). Screenshot via Chrome remote debugging (CDP) op poort 9223, app op `http://localhost:9150`.

## 6. Screenshot

Bestand: `docs/sdd-screenshots/web-18-agenda-filter.png`.

Web, Chrome, donker thema (systeem). Ingelogd als pedroA. Geen wachtwoord in beeld.

Agenda is actief in de NavigationRail. Bovenaan drie FilterChips: `R2t034837` (aangevinkt, vinkje), `Team Alpha` en `Team Beta`. Rechts daarvan de knop **Alles tonen**. Daaronder één komend item: `AT20r2` van team `R2t034837` op 19 augustus 2026. De overige items van Alpha en Beta zijn weggefilterd.
