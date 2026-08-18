# Rapport T-05 T-10 — QR scannen en matches

Vul dit sjabloon volledig in. Kopieer het naar `docs/rapport-T-XX.md` en vervang XX door het taaknummer.
Laat geen veld leeg. Weet je iets niet, schrijf dan letterlijk `NIET GEDAAN` of `WEET IK NIET`.

Verzin niets. Als een stap niet is uitgevoerd, schrijf dan dat hij niet is uitgevoerd. Een eerlijk rapport met
drie mislukte stappen is bruikbaar. Een rapport dat succes meldt terwijl er iets niet is gedaan, is schadelijk,
want er wordt documentatie op gebaseerd die daarna niet klopt.

---

## 1. Wat er gevraagd was

Taaknummer: T-05 en T-10 (dezelfde branch)
Requirements: FR-10, FR-15, FR-16
Branch: `feature/T-05-T-10` vanaf `origin/dev`

## 2. Bestanden

Nieuw aangemaakt:
- `lib/features/teams/qr_scan_screen.dart` — scanscherm met `mobile_scanner`, uitleg bij geweigerde camera
- `lib/features/teams/qr_scan_controller.dart` — leesTeamId, huidigeGebruikerId, voegGebruikerToe
- `lib/data/repositories/match_repository.dart` — ophalen, aanmaken, ontvangen invites, beantwoorden
- `lib/features/matches/invite_overgangen.dart` — toegestane statusovergangen
- `lib/features/matches/match_form_controller.dart` — formulierlogica voor een nieuwe match
- `lib/features/matches/match_form_screen.dart` — scherm om een match aan te maken
- `lib/features/matches/match_invites_controller.dart` — ontvangen uitnodigingen laden en beantwoorden
- `lib/features/matches/match_invites_screen.dart` — lijst met knoppen per toegestane overgang
- `test/unit/qr_scan_controller_test.dart` — geldige code, al lid, team niet gevonden, ongeldig formaat
- `test/widget/qr_scan_screen_test.dart` — scan-knop bestaat, geweigerde camera toont uitleg
- `test/unit/match_repository_test.dart` — aanmaken, accepteren, afwijzen
- `test/unit/invite_overgangen_test.dart` — ongeldige overgang wordt niet aangeboden
- `test/widget/match_invites_screen_test.dart` — knoppen per status
- `docs/platformverschillen.md` — camera op web versus Android
- `docs/advies-qr-scannen.md` — keuzes bij T-05
- `docs/advies-matches.md` — keuzes bij T-10
- `docs/rapport-T05-T10.md` — dit rapport

Gewijzigd:
- `lib/features/teams/teams_screen.dart` — scan-knop naast Nieuw team, plus een knop naar matches
- `lib/main.dart` — provider voor `MatchRepository`
- `android/app/src/main/AndroidManifest.xml` — `CAMERA` als sibling van `application`
- `pubspec.yaml` / `pubspec.lock` — `permission_handler` voor de knop Instellingen
- `test/unit/team_uitnodiging_test.dart` — drie ongeldige codes voor `leesTeamId`

Verwijderd:
-

## 3. Commando's die ik heb gedraaid

Plak de uitvoer erbij, ook als die lang is. Niet samenvatten.

```
$ flutter analyze
Analyzing T-05-T-10...
No issues found! (ran in 4.0s)
```

```
$ flutter test
00:00 +0: loading C:/Users/pmec/Documents/School/CPD/worktrees/T-05-T-10/test/unit/api_client_test.dart
00:18 +113: All tests passed!
```

De volledige suite eindigde op 113 geslaagde tests, 0 gefaald. Dat was na T-10. Na T-05 alleen stond de teller op 103.

```
$ dart format .
Formatted 52 files (0 changed) in 0.58 seconds.
```

Na T-05: `dart format lib test` wijzigde 4 bestanden, daarna `flutter analyze` schoon en `flutter test` 103 groen.
Na T-10: opnieuw format, analyze schoon, 113 groen.

`flutter run -d emulator-5554`:
```
√ Built build\app\outputs\flutter-apk\app-debug.apk
Error: ADB exited with exit code 1
adb.exe: failed to install ... app-debug.apk: cmd: Can't find service: package
Error launching application on sdk gphone64 x86 64.
```

`flutter run -d chrome --web-port 8090`:
```
Launching lib\main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...             57.5s
Flutter run key commands.
```

## 4. Tests

| Testbestand | Aantal tests | Geslaagd | Gefaald |
|---|---|---|---|
| `test/unit/qr_scan_controller_test.dart` | 4 | 4 | 0 |
| `test/widget/qr_scan_screen_test.dart` | 2 | 2 | 0 |
| `test/unit/team_uitnodiging_test.dart` (leesTeamId, nieuw) | 3 | 3 | 0 |
| `test/unit/match_repository_test.dart` | 4 | 4 | 0 |
| `test/unit/invite_overgangen_test.dart` | 3 | 3 | 0 |
| `test/widget/match_invites_screen_test.dart` | 3 | 3 | 0 |
| hele suite | 113 | 113 | 0 |

Welk requirement dekt elke test? Noem per test het FR- of NFR-nummer.

- `qr_scan_controller_test`: FR-10 (ongeldige code, toevoegen, al lid, team niet gevonden)
- `qr_scan_screen_test` scan-knop: FR-10
- `qr_scan_screen_test` geweigerde camera: FR-10, NFR-02
- `team_uitnodiging_test` leesTeamId: FR-10
- `match_repository_test` aanmaken: FR-15
- `match_repository_test` accepteren en afwijzen: FR-16
- `invite_overgangen_test`: FR-16
- `match_invites_screen_test`: FR-16 (ongeldige overgang niet aangeboden)

## 5. Handmatig getest

| Platform | Getest? | Wat ik heb gedaan | Wat er gebeurde |
|---|---|---|---|
| Web (`flutter run -d chrome`) | deels | `flutter run -d chrome --web-port 8090` | De app startte. Debug service luisterde. Ik heb niet ingelogd en dus de scanner en matches niet met de muis doorlopen |
| Android (emulator of toestel) | deels | Emulator `cpd_test` als `emulator-5554` gestart. `assembleDebug` gebouwd | APK is gebouwd. Installeren faalde: `Can't find service: package`. `bootanim` bleef op `running`. Geen app op het scherm, geen camera geprobeerd |

Heb je het niet handmatig gedraaid, schrijf dan `NIET GEDAAN` en waarom.

Live QR-scan met een echte of emulatorecamera: NIET GEDAAN. Reden: de app kwam niet op de emulator. Op web is niet ingelogd. De widgettest voor geweigerde camera start `MobileScanner` expres niet.

## 6. Acceptatiecriteria uit de taak

Neem elk acceptatiecriterium uit de taakbeschrijving letterlijk over en zet erachter of het gehaald is.

| Criterium (letterlijk uit de taak) | Gehaald? | Hoe vastgesteld |
|---|---|---|
| knop naast Nieuw team | ja | widgettest plus code in `teams_screen.dart` |
| Flow: leesTeamId → huidigeGebruikerId → voegGebruikerToe → overzicht herladen + bevestiging | ja | `QrScanController` en terugkeer in `teams_screen.dart` |
| 1. Toestemming geweigerd: uitleg + knop instellingen | ja | widgettest `cameraGeweigerd: true` |
| 2. Verkeerd formaat: melding, scanner blijft | ja | controller-test plus scanscherm laat de scanner lopen |
| 3. Al lid: nette melding | ja | controller-test, geen tweede `addUser` |
| 4. Team niet gevonden: nette melding | ja | controller-test, tekst uit `NietGevondenException` |
| CAMERA in main manifest sibling van application | ja | `AndroidManifest.xml` |
| Web HTTPS/localhost in platformverschillen.md | ja | `docs/platformverschillen.md` |
| Widget tests: knop bestaat; geweigerde camera toont uitleg | ja | `qr_scan_screen_test.dart` |
| Scannen werkt op Android met een echte camera | nee | emulator nam de APK niet aan; geen fysiek toestel gebruikt |
| Op web werkt het op localhost, of het verschil staat gedocumenteerd | deels | web start op localhost; camera zelf niet live geprobeerd; verschil staat in `platformverschillen.md` |
| Aanmaken (beheerder) | ja | formulier plus repository-test |
| Beantwoorden: pending→accepted/declined, accepted→canceled | ja | `toegestaneInviteOvergangen` plus widgettest |
| Testbare functie voor toegestane overgangen | ja | `invite_overgangen.dart` |
| Roosters niet wijzigen | ja | `lib/features/schedule/` niet aangeraakt |
| Tests: repository aanmaken/accepteren/afwijzen | ja | `match_repository_test.dart` |
| ongeldige overgang niet aangeboden | ja | unit- en widgettest |
| Een geaccepteerde match in beide roosters de juiste status toont | nee | roosters niet gewijzigd, zoals gevraagd |

## 7. Wat ik NIET heb gedaan

Alles uit de taak dat je hebt overgeslagen, met de reden. Ook kleine dingen.

- Live QR-scan op Android. De emulator startte niet tot `package`.
- Inloggen op web om de scan-knop of matches met de muis te klikken.
- Dubbel-`addUser` opnieuw meten. De bestaande meting in `api-waargenomen-gedrag.md` stap 15 (tweede meting) volstond. Dat bestand is niet aangepast.
- Roosters bijwerken na een geaccepteerde match. De opdracht zei roosters niet wijzigen.
- `home_shell.dart`, `login_screen.dart`, `register_screen.dart`, `errors.dart` en `lib/features/schedule/` niet aangeraakt.

## 8. Keuzes die ik heb gemaakt

Elke technische keuze die niet letterlijk in de taak stond. Per keuze: wat je koos, welk alternatief je had, en
waarom. Dit is materiaal voor het adviesrapport, dus wees concreet.

| Keuze | Alternatief | Reden |
|---|---|---|
| `permission_handler.openAppSettings` voor de knop Instellingen | Eigen MethodChannel in Kotlin | Geen extra native code. Op web doet de knop niets, dat staat in `platformverschillen.md` |
| Eerst `haalTeam`, daarna pas `voegGebruikerToe` | Alleen `addUser` en 200 als succes | Dubbel toevoegen geeft 200 zonder fout. Zonder de check is "al lid" niet te zien |
| `MatchRepository` nieuw aangemaakt, niet aangevuld | Wachten tot T-08 op `dev` staat | Op `origin/dev` bestond het bestand niet |
| Matches-ingang in de AppBar van het teamoverzicht | Knop in teamdetail | Teamdetail stond niet op de toegestane lijst. Zonder ingang zijn de matchschermen onbereikbaar |
| Overgangen in een aparte functie | Alleen in de widget | De taak vroeg een testbare functie |

## 9. Waar ik tegenaan liep

Fouten, verrassingen, dingen die anders werkten dan verwacht. Ook als je ze hebt opgelost.

- `match_repository.dart` ontbrak op `origin/dev`. De opdracht zei aanvullen. Ik heb het bestand compleet gezet, inclusief ophalen.
- `DropdownButtonFormField.value` is deprecated na Flutter 3.33. Vervangen door `initialValue` plus een `ValueKey`.
- De emulator meldde `emulator-5554` als `device`, maar `package` ontbrak. APK bouwen lukte, installeren niet.
- `mobile_scanner` geeft een Kotlin Gradle Plugin-waarschuwing bij de Android-build. De APK kwam er toch.

## 10. Aannames

Alles waarvan je niet zeker wist of het klopte, maar waar je toch vanuit bent gegaan.

- `GET /matches/invites` levert alleen ontvangen uitnodigingen. Dat staat in de meting van T-01.
- Een tweede `addUser` van hetzelfde lid is 200 zonder fout. Dat staat in de ledenmeting, stap 15. Niet opnieuw gemeten.
- De knop Instellingen op web mag niets openen. De browser houdt cameratoestemming zelf bij.

## 11. Git

Branch: `feature/T-05-T-10`
Commits (`git log --oneline` van deze branch):
```
da8b134 docs Rapport T-05 en T-10
d8a6b8f T-10 Matches aanmaken en uitnodigingen beantwoorden
8d3672b T-05 QR-uitnodiging scannen
```
Pull request aangemaakt: ja, https://github.com/pmecpmec/CPD/pull/12
Gemerged naar `dev`: nee

## 12. Voor de volgende taak

Wat moet iemand weten die hierna verdergaat?

- De scanner gebruikt `TeamUitnodiging.leesTeamId`. Geen tweede parser maken.
- Invite-id komt alleen uit `GET /matches/invites`. Niet uit `Match.invites`.
- Roosters moeten de status uit `invites[].status` blijven lezen. Deze branch wijzigt ze niet.
- Android live-scan is nog niet gedaan. Dat hoort op een emulator die `package` heeft, of op een echte telefoon.
- `permission_handler` staat in de pubspec vanwege de knop Instellingen op Android.
