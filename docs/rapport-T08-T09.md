# Rapport T-08 / T-09: Teamrooster, persoonlijk rooster en teamlijst wissen

Vul dit sjabloon volledig in. Kopieer het naar `docs/rapport-T-XX.md` en vervang XX door het taaknummer.
Laat geen veld leeg. Weet je iets niet, schrijf dan letterlijk `NIET GEDAAN` of `WEET IK NIET`.

Verzin niets. Als een stap niet is uitgevoerd, schrijf dan dat hij niet is uitgevoerd. Een eerlijk rapport met
drie mislukte stappen is bruikbaar. Een rapport dat succes meldt terwijl er iets niet is gedaan, is schadelijk,
want er wordt documentatie op gebaseerd die daarna niet klopt.

---

## 1. Wat er gevraagd was

Taaknummer: T-08, T-09, plus een extra fix op dezelfde branch, plus STAP 0 (merge `dev` naar `main`)
Requirements: FR-13, FR-14, NFR-01, NFR-02
Branch: `feature/T-08-T-09-roosters`

STAP 0: pull request van `dev` naar `main`, mergen, CI-jobs op `main` afwachten.

STAP 1 (T-08): teamrooster van één team, sortering en scheiding verleden/toekomst in een aparte functie met vaste tijd, matchstatus in het Nederlands, lege staat, knop in het teamdetail, leeskant van `MatchRepository`.

STAP 2 (T-09): persoonlijk rooster over alle teams, ontdubbelen van dezelfde match via twee teams, hoofdnavigatie Teams/Agenda (`NavigationBar` smal, `NavigationRail` breed).

Extra opdracht: `TeamsController.wis()` bij uitloggen, vóór `AuthController.logout()`. `_laadt` in `maakTeam()` aan het begin true en in `finally` false. Unit test dat de lijst leeg is na `wis()`.

---

## 2. Bestanden

Nieuw aangemaakt:
- `lib/data/repositories/match_repository.dart`: interface en `ApiMatchRepository` met alleen `haalMatches()` en `haalMatch(int id)`
- `lib/features/schedule/rooster.dart`: `RoosterItem`, `verdeelRooster`, `matchStatusLabel`, later `ontdubbelRoosterItems` en `matchTeamNaam`
- `lib/features/schedule/rooster_lijst.dart`: `LeegRooster` en `RoosterLijst`
- `lib/features/schedule/team_schedule_controller.dart`: events en matches van één team
- `lib/features/schedule/team_schedule_screen.dart`: scherm teamrooster
- `lib/features/schedule/my_schedule_controller.dart`: events en matches van alle eigen teams, met ontdubbelen
- `lib/features/schedule/my_schedule_screen.dart`: scherm persoonlijk rooster
- `lib/features/teams/home_shell.dart`: tabbladen Teams en Agenda
- `test/unit/match_repository_test.dart`: leeskant van matches
- `test/unit/schedule_sortering_test.dart`: sortering en scheiding rond een vaste tijd
- `test/unit/persoonlijk_rooster_test.dart`: ontdubbelen op match-id
- `test/unit/teams_controller_test.dart`: `wis()` maakt de lijst leeg
- `docs/rapport-T08-T09.md`: dit rapport

Gewijzigd:
- `lib/main.dart`: `MatchRepository` en `MyScheduleController` als provider, ingelogd scherm is `HomeShell`
- `lib/features/teams/team_detail_screen.dart`: knop Rooster
- `lib/features/teams/teams_controller.dart`: `wis()` en `_laadt` in `maakTeam()`
- `lib/features/teams/teams_screen.dart`: `wis()` vóór uitloggen, daarna ook `MyScheduleController.wis()`
- `test/widget/team_detail_screen_test.dart`: scrollt naar "Team verwijderen" omdat de extra knop die knop buiten beeld duwde

Verwijderd:
- Niets.

---

## 3. Commando's die ik heb gedraaid

`dart format .` is niet gedraaid. `build/` heeft eerder een kapot Gradle-pad. Gebruikt is `dart format lib test`.

Na T-09, op branch `feature/T-08-T-09-roosters`:

```
$ dart format lib test
Formatted 49 files (0 changed) in 0.10 seconds.
```

```
$ flutter analyze
Analyzing crossplatformdevelopment...
No issues found! (ran in 2.0s)
```

```
$ flutter test
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
00:00 +17: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents haalt de events van alle teams van de gebruiker op
00:00 +18: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents geeft een lege lijst terug wanneer er niets gepland is
00:00 +19: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents geeft een lege lijst terug bij een onverwacht antwoord
00:00 +20: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvent leest één event op id
00:00 +21: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvent meldt het wanneer het event niet bestaat
00:00 +22: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent verstuurt titel, tijden in UTC en een coördinatenpaar
00:00 +23: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent laat de locatie weg wanneer die niet is opgegeven
00:00 +24: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent geeft een GeenRechtenException als een lid geen event mag maken
00:00 +25: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: wijzigEvent en verwijderEvent stuurt een PUT naar het event zonder teamId mee te sturen
00:00 +26: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: wijzigEvent en verwijderEvent stuurt een DELETE naar het event
00:00 +27: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches haalt de lijst op, inclusief matches van andere teams
00:00 +28: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches geeft een lege lijst terug wanneer er niets is
00:00 +29: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatches geeft een lege lijst terug bij een onverwacht antwoord
00:00 +30: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatch leest één match op id
00:00 +31: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/match_repository_test.dart: haalMatch meldt het wanneer de match niet bestaat
00:00 +32: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: User leest id en naam uit het inlogantwoord
00:00 +33: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leest alle velden, met de leden onder de sleutel members
00:00 +34: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leidt de rol af uit ownerId, want de leden hebben er geen
00:00 +35: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team houdt null in description en metadata leeg
00:00 +36: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team laat ownerId leeg als de API het weglaat
00:00 +37: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest titel, tijden, locatie en team
00:00 +38: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest de tijden als UTC en zet ze om naar lokale tijd
00:00 +39: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event stuurt de tijden als UTC terug naar de API
00:00 +40: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event laat de locatie leeg wanneer die ontbreekt
00:00 +41: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match legt het organiserende team vast in teamId en team
00:00 +42: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match houdt de status per uitnodiging bij, niet op de match zelf
00:00 +43: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match noemt alle betrokken teams, organisator eerst
00:00 +44: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match als geaccepteerd als elke uitnodiging dat is
00:00 +45: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match met een afwijzing niet als geaccepteerd
00:00 +46: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match een match zonder uitnodigingen geldt niet als geaccepteerd
00:00 +47: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest de vorm uit GET /matches/invites, met invite-id
00:00 +48: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest het antwoord op een geaccepteerde uitnodiging
00:00 +49: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite valt terug op pending bij een onbekende status
00:00 +50: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: GeoLocatie leest coördinaten, ook een hele graad zonder decimalen
00:01 +51: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: dezelfde match via twee teams wordt één item met beide namen
00:01 +52: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: twee verschillende matches blijven twee items
00:01 +53: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/persoonlijk_rooster_test.dart: events worden niet samengevoegd, ook niet bij hetzelfde id
00:01 +54: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl gebruikt op Android het geo-schema met een pin op de locatie
00:01 +55: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl zet een leesbare plaatsnaam als label bij de pin
00:01 +56: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl laat het label weg wanneer er geen plaatsnaam bekend is
00:01 +57: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl opent op web een Google Maps-route over https
00:01 +58: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl houdt negatieve coördinaten heel op beide platformen
00:01 +59: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl loopt niet stuk op de nulmeridiaan
00:01 +60: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform kiest het geo-schema op een Android-toestel
00:01 +61: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform valt op andere platformen terug op de web-URL
00:01 +62: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute opent de URL die bij het gekozen platform hoort
00:01 +63: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute meldt het wanneer er niets op de URL reageert
00:01 +64: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute valt niet om als er op Android geen kaart-app staat
00:01 +65: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet een leeg rooster in twee lege delen
00:01 +66: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet afgelopen items in het verleden en de rest in de toekomst
00:01 +67: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert de toekomst op begintijd, vroegste eerst
00:01 +68: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert het verleden op begintijd, meest recent eerst
00:01 +69: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster sorteert bij gelijke begintijd op titel
00:01 +70: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: verdeelRooster zet een item dat precies nu eindigt bij de toekomst
00:01 +71: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: matchStatusLabel vertaalt pending, accepted en declined naar Nederlandse labels
00:01 +72: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: matchStatusLabel toont voor de organisator of iedereen heeft geaccepteerd
00:01 +73: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: RoosterItem.vanEvent en vanMatch neemt de teamnaam uit het ingebedde team van het event
00:01 +74: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/schedule_sortering_test.dart: RoosterItem.vanEvent en vanMatch zet bij een match de status en de betrokken teamnamen
00:01 +75: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/teams_controller_test.dart: wis maakt de lijst en de foutmelding leeg
00:01 +76: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/teams_controller_test.dart: wis wist ook een eerdere foutmelding
00:01 +77: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode heeft de afgesproken vorm en bevat het team-id
00:01 +78: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode begint met het voorvoegsel en eindigt op het team-id
00:01 +79: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode geeft elk team een eigen code
00:01 +80: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode een gebouwde code is weer terug te lezen
00:02 +81: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_detail_screen_test.dart: toont titel, team, tijd, locatie en omschrijving
00:03 +82: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:03 +83: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:03 +84: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:04 +85: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:04 +86: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:04 +87: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:04 +88: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:04 +89: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:04 +90: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:04 +91: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:04 +92: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:05 +93: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:05 +94: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:05 +95: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:05 +96: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:05 +97: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:05 +98: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:05 +99: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:05 +100: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:05 +101: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:05 +102: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lengtegraad buiten het bereik wordt geweigerd
00:06 +103: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lengtegraad buiten het bereik wordt geweigerd
00:06 +104: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lengtegraad buiten het bereik wordt geweigerd
00:06 +105: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lengtegraad buiten het bereik wordt geweigerd
00:06 +106: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) verlaten vraagt eerst om bevestiging en sluit dan het scherm
00:06 +107: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) verlaten vraagt eerst om bevestiging en sluit dan het scherm
00:06 +108: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden stuurt titel, periode, coördinaten en plaatsnaam mee
00:06 +109: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert een lid na bevestiging
00:06 +110: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden een event zonder coördinaten krijgt geen locatie
00:06 +111: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert het team na bevestiging
00:07 +112: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden toont de melding uit errors.dart als de server weigert
00:07 +113: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden toont de melding uit errors.dart als de server weigert
00:07 +114: All tests passed!
```

Flutter print niet elke testnaam als widgettests parallel eindigen. Het eindcijfer is 114 geslaagd, 0 gefaald.

STAP 0, CI op `main` na merge van PR #8 (`gh run view 31983970469`):

| Job | Conclusie |
|---|---|
| Analyse en test | success |
| Webbuild | success |
| Androidbuild | success |

Deploy-run `31983970503`:

| Job | Conclusie |
|---|---|
| Webversie bouwen | failure |
| Publiceren | skipped |

Foutmelding van `actions/configure-pages@v5`:

```
Get Pages site failed. Please verify that the repository has Pages enabled and configured to build using GitHub Actions, or consider exploring the `enablement` parameter for this action. Error: Not Found
HttpError: Not Found
```

---

## 4. Tests

| Testbestand | Aantal tests | Geslaagd | Gefaald |
|---|---|---|---|
| `test/unit/api_client_test.dart` | 10 | 10 | 0 |
| `test/unit/auth_repository_test.dart` | 7 | 7 | 0 |
| `test/unit/event_repository_test.dart` | 10 | 10 | 0 |
| `test/unit/match_repository_test.dart` | 5 | 5 | 0 |
| `test/unit/models_test.dart` | 19 | 19 | 0 |
| `test/unit/persoonlijk_rooster_test.dart` | 3 | 3 | 0 |
| `test/unit/route_starter_test.dart` | 11 | 11 | 0 |
| `test/unit/schedule_sortering_test.dart` | 10 | 10 | 0 |
| `test/unit/teams_controller_test.dart` | 2 | 2 | 0 |
| `test/unit/team_uitnodiging_test.dart` | 4 | 4 | 0 |
| `test/widget/event_detail_screen_test.dart` | 6 | 6 | 0 |
| `test/widget/event_form_screen_test.dart` | 9 | 9 | 0 |
| `test/widget/qr_invite_dialog_test.dart` | 2 | 2 | 0 |
| `test/widget/login_screen_test.dart` | 5 | 5 | 0 |
| `test/widget/register_screen_test.dart` | 1 | 1 | 0 |
| `test/widget/teams_screen_test.dart` | 1 | 1 | 0 |
| `test/widget/team_detail_screen_test.dart` | 9 | 9 | 0 |
| Totaal | 114 | 114 | 0 |

Aantallen zijn het aantal `test(` / `testWidgets(` in het bestand. Flutter telt bij groepen extra regels in de log. Het suite-eindcijfer is 114.

Welk requirement dekt elke test? Nieuw in deze taak:

- `schedule_sortering_test`: FR-13 (sortering, scheiding, matchstatus)
- `match_repository_test`: basis voor FR-13 (lezen van matches)
- `persoonlijk_rooster_test`: FR-14 (ontdubbelen, beide teamnamen)
- `teams_controller_test`: NFR-02 (geen oude lijst na uitloggen)

Bestaande tests dekken FR-01 tot FR-12, FR-17, NFR-03, NFR-06 zoals in hun eigen rapporten.

---

## 5. Handmatig getest

| Platform | Getest? | Wat ik heb gedaan | Wat er gebeurde |
|---|---|---|---|
| Web (`flutter run -d chrome`) | deels | `flutter run -d chrome --web-port 8765` | De app startte. `http://localhost:8765` gaf HTTP 200. Inloggen, teamrooster, agenda en het wisselen van balk naar rail bij smaller maken: NIET GEDAAN. Er was geen bruikbaar browservenster om in te loggen of te verslepen. |
| Android (emulator of toestel) | ja | emulator-5554, account `hr17014445` | Zie de handelingen hieronder. |

Android:

`flutter run -d emulator-5554` bouwde `app-debug.apk` en installeerde die. Daarna stopte het proces met exitcode 1, met in de log `Width is zero. 0,0`. De APK stond er wel. Daarna `adb shell am start` op `com.example.crossplatformdevelopment/.MainActivity`.

Sessie was bewaard. Scherm Mijn teams met team Herstelteam. Onderaan een `NavigationBar` met Teams (actief) en Agenda.

Teamdetail Herstelteam geopend. Knop Rooster getikt. Eerst de lege staat: "Er staat nog niets in dit rooster". Terug. Event aanmaken, titel `Testevent`, standaardtijden 17 augustus 2026 03:00 tot 04:00. Na versturen terug in het teamdetail. Rooster opnieuw geopend. Kopregel "Komt eraan", kaart `Testevent` met `17 augustus 2026, 03:00 – 04:00`.

Terug naar Mijn teams. Tab Agenda. Eerst de lege staat. De agenda was al geladen toen HomeShell opende, vóór het nieuwe event. Omlaag getrokken om te verversen. Daarna "Komt eraan", `Testevent`, tijd, en teamnaam `Herstelteam`.

Matchstatus in het rooster: NIET GEDAAN. Er was geen match. T-10 maakt matches.

NavigatieRail (breed scherm): NIET GEDAAN. De emulator is smaller dan 600 logische pixels, dus alleen de balk onderaan.

---

## 6. Acceptatiecriteria uit de taak

| Criterium (letterlijk uit de taak) | Gehaald? | Hoe vastgesteld |
|---|---|---|
| Toon alle events en matches van dat team, gesorteerd op tijd | ja | Android: Testevent onder Komt eraan. Unit tests op `verdeelRooster`. Matches: alleen unit tests, geen echte match in de app. |
| Verleden en toekomst zijn duidelijk gescheiden, bijvoorbeeld met een kopregel en gedempte kleur | ja | Kopregels Komt eraan en Geweest in `rooster_lijst.dart`. Geweest niet handmatig gezien (geen afgelopen item). |
| Bij een match staat de status erbij: in afwachting, geaccepteerd, afgewezen | deels | `matchStatusLabel` vertaalt pending/accepted/declined. Unit tests groen. Geen echte match op het toestel. |
| Lege staat met uitleg wanneer er niets gepland is | ja | Android, vóór het aanmaken van Testevent. |
| `test/unit/schedule_sortering_test.dart` controleert de sortering en de scheiding rond het huidige moment, met een vaste tijd als invoer | ja | 10 tests, groen. |
| Het scherm werkt op web en Android | deels | Android: ja. Web: de debug-server startte, het scherm is daar niet geopend. |
| `test/unit/persoonlijk_rooster_test.dart` bewijst het ontdubbelen: bouw een lijst met dezelfde match via twee teams en controleer dat er één item overblijft met beide teamnamen | ja | Test `dezelfde match via twee teams wordt één item met beide namen`. |
| De navigatie wisselt van vorm bij het verkleinen van het venster op web | nee | Code: `HomeShell.breekpunt = 600`. Op Android de balk. Venster op web niet versleept. |
| Voeg een methode `wis()` toe die de lijst en de foutmelding leegmaakt, en roep die aan op de uitlogknop vóór `AuthController.logout()` | ja | `TeamsController.wis()`, aanroep in `teams_screen.dart`. |
| Schrijf er een unit test voor die bewijst dat de lijst leeg is na `wis()` | ja | `test/unit/teams_controller_test.dart`. |
| Zet `_laadt` aan het begin van `maakTeam()` op true en in een `finally` weer op false | ja | Zelfde patroon als `laad()`. |
| `flutter analyze` geen enkele waarschuwing | ja | `No issues found!` |
| `flutter test` groen, inclusief de tests uit deze taak | ja | 114 groen. |
| Pull request van `dev` naar `main`, mergen, CI-jobs melden | ja | PR #8, https://github.com/pmecpmec/CPD/pull/8. CI groen, Deploy rood op Pages. |

---

## 7. Wat ik NIET heb gedaan

- Web niet ingelogd. Teamrooster, agenda en het wisselen van balk naar rail op web zijn niet gezien.
- Geen echte match in de roosters. Daar is T-10 voor.
- Kopregel Geweest niet handmatig gezien.
- `dart format .` over de hele boom inclusief `build/` niet groen gedraaid.
- GitHub Pages niet aangezet. Deploy op `main` blijft falen zolang Pages uitstaat.
- Geen widgettest die `HomeShell` op twee breedtes pompt.
- `flutter run` op de emulator bleef niet hangen als debug-sessie. Testen daarna via `adb`.

---

## 8. Keuzes die ik heb gemaakt

| Keuze | Alternatief | Reden |
|---|---|---|
| `MatchRepository` alleen lezen | Alvast aanmaken/accepteren bouwen | T-10 is die kant. De taak zei alleen `haalMatches` en `haalMatch`. |
| `verdeelRooster(items, nu:)` zonder `DateTime.now()` in de functie | Klok in de functie | De taak vroeg een vaste tijd in de test. |
| Ontdubbelen op match-id, met per betrokken team eerst een regel | `RoosterItem.vanMatch` met alle teamnamen in één keer | Via twee teams moet de naam van elk eigen team bewaard blijven. `vanMatch` zet organisator plus alle invites, niet alleen de eigen teams. |
| `HomeShell` met `IndexedStack` | Alleen het actieve tabblad bouwen | De tab-state blijft staan. Nadeel: de agenda laadt één keer bij start. Een event dat daarna wordt gemaakt, verschijnt pas na omlaag trekken. |
| Breekpunt 600 logische pixels | Material-standaard 840 of een andere grens | 600 is een gangbare grens tussen telefoon en breed venster. Op de emulator blijft de balk. |
| `MyScheduleController.wis()` bij uitloggen, met `ProviderNotFoundException` als die provider ontbreekt | Alleen `TeamsController.wis()` | Zelfde flash-bug als bij teams. Widgettests van `TeamsScreen` zetten de agenda-controller niet. |
| Geparkeerde T-08-code als startpunt, `library;`-fout en ontbrekende `rooster_lijst.dart` opnieuw gedaan | Blind kopiëren | Die map gaf analyze-fouten. |

---

## 9. Waar ik tegenaan liep

- Geparkeerde T-08: `library;` stond ná een import. `rooster_lijst.dart` ontbrak. Analyze zou falen bij blind kopiëren.
- `GET /matches` geeft alle matches van de server. Filteren gebeurt in de controller op team-id (T-08) of lidmaatschap (T-09).
- `flutter run -d emulator-5554` installeerde de APK en stopte daarna met exitcode 1 (`Width is zero`). `adb am start` toonde de app wel.
- `flutter run -d chrome --web-port 8765` startte. Inloggen in dat venster is hier niet gelukt.
- Agenda toonde na het aanmaken van Testevent eerst de lege staat. Omlaag trekken haalde het event op.
- Extra knop Rooster duwde "Team verwijderen" in de widgettest buiten 600 px. Die test scrollt nu naar die knop.

---

## 10. Aannames

- Account `hr17014445` / `geheim123` uit het herstelrapport bestond nog. De app opende Mijn teams zonder inlogscherm.
- Testevent is op de echte API aangemaakt. Dat event staat daarna in GET /events.
- Deploy-falen op Pages is hetzelfde als eerder: private repo, GitHub Pages niet aan.
- `InviteStatus.label` is de juiste Nederlandse tekst voor in afwachting / geaccepteerd / afgewezen.

---

## 11. Git

Branch: `feature/T-08-T-09-roosters`
Commits (`git log --oneline` van deze branch ten opzichte van `origin/dev`):
```
9cf2bb4 docs: rapport T-08 T-09 met analyze, test en handmatige Androidcheck
e76ee38 T-09 Persoonlijk rooster met ontdubbelen en hoofdnavigatie
dc8fd86 fix: teamlijst wissen bij uitloggen en laadstatus bij aanmaken
f0862f2 T-08 Teamrooster met sortering op vaste tijd
```
Daarna volgt op dezelfde branch de commit die deze PR-URL vastlegt.

Pull request aangemaakt: ja (https://github.com/pmecpmec/CPD/pull/9)
Gemerged naar `dev`: nee

STAP 0, niet op deze feature-branch:
- PR `dev` naar `main`: https://github.com/pmecpmec/CPD/pull/8
- Gemerged: ja, 2026-08-17T01:06:38Z, merge-commit `69907c8`
- CI `31983970469`: groen (Analyse en test, Webbuild, Androidbuild)
- Deploy `31983970503`: rood (Pages Not Found)

---

## 12. Voor de volgende taak

Constructor-signaturen:

```
const TeamScheduleScreen({super.key, required this.teamNaam});
static Future<void> open(BuildContext context, {required int teamId, required String teamNaam});

const MyScheduleScreen({super.key});
const HomeShell({super.key});
```

`MatchRepository` heeft alleen lezen. T-10 moet aanmaken, accepteren en afwijzen toevoegen, plus tests daarvoor.

De agenda laadt in `initState` van `MyScheduleScreen`. `IndexedStack` houdt dat scherm in leven. Na een nieuw event elders: omlaag trekken, of later `laad()` aanroepen vanuit het eventformulier. Dat is nu niet gebouwd.

Web: balk versus rail is code, geen handmatige check. Iemand met een Chrome-venster kan het venster smaller maken rond 600 px.

`docs/rapport-SJABLOON.md` en `docs/rapport-verificatie.md` staan untracked. Die horen niet in deze PR.
