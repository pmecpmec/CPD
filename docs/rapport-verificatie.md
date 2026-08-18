# Rapport verificatie — 17 augustus 2026

Verificatie-agent. Geen features gebouwd. Geen bugs opgelost (behalve dat stap 3 dat zou toestaan; daar faalde niets).
Gelezen: `.cursor/rules/cpd.mdc` en `docs/rapport-SJABLOON.md`.

Werkmap bij aanvang: branch `dev` op `61d75a9`, gelijk aan `origin/dev`, met lokale wijzigingen die niet gecommit zijn.

---

## STAP 1 — Git

Commando's:

```
$ git checkout dev && git pull
M	.cursor/rules/cpd.mdc
M	.gitignore
Your branch is up to date with 'origin/dev'.
Switched to branch 'dev'
Already up to date.
```

```
$ git log --oneline -15
61d75a9 chore: werkregels als cursor rule vastleggen
37e5b23 Merge T-03: teamdetail met leden, rollen en privacy (FR-06, FR-07, FR-08)
6b4e104 Merge T-07: eventdetail met routeplanner (FR-12, FR-17)
40cf4b7 T-03 Teamdetail met leden, rollen en privacy (FR-06, FR-07, FR-08)
09c40db T-03 Ledenacties van de API gemeten en vastgelegd
b7dc5c0 T-07 Keuzes rond de routeplanner vastgelegd als advies
0b4863a T-07 Eventdetail met titel, tijd, locatie, team en routeknop (FR-12)
f59be96 T-07 Routeplanner met een kaart-URL per platform (FR-17)
bfe885f Merge FR-01: foutmelding uit het error-veld van de API lezen
d57ad8a FR-01 Foutmelding uit het error-veld van de API lezen
47cab99 dart format over de hele codebase, zodat de CI-formatteerstap groen staat
848d261 Merge T-02: EventRepository met tests en provider
e364960 Merge T-01: modellen bevestigd tegen de echte API
f5a5555 T-01 Waargenomen API-antwoorden per endpoint vastgelegd
da47748 T-01 Modellen bevestigd tegen de echte API en getest met waargenomen JSON
```

```
$ git branch -a
  chore/T-01-modellen-bevestigen
* dev
+ docs/android-verificatie
  feature/T-02-event-repository
  feature/T-03-teamdetail
  feature/T-04-qr-tonen
  feature/T-06-event-aanmaken
  feature/T-07-eventdetail-route
  feature/T-08-teamrooster
  fix/foutveld-api-client
  main
  remotes/origin/HEAD -> origin/main
  remotes/origin/chore/T-01-modellen-bevestigen
  remotes/origin/dev
  remotes/origin/feature/T-02-event-repository
  remotes/origin/feature/T-03-teamdetail
  remotes/origin/feature/T-04-qr-tonen
  remotes/origin/feature/T-06-event-aanmaken
  remotes/origin/feature/T-07-eventdetail-route
  remotes/origin/fix/foutveld-api-client
  remotes/origin/main
```

```
$ git rev-list --count main..dev
20
```

Die 20 telt de **lokale** `main`, en die loopt achter op `origin/main`. Dat cijfer is dus misleidend.

```
$ git rev-list --count origin/main..origin/dev
0

$ git log --oneline origin/dev..origin/main
c828f08 Merge pull request #3 from pmecpmec/dev
```

**Uitkomst stap 1**

- Op GitHub loopt `main` **niet** achter op `dev`. `origin/dev` heeft 0 commits die `origin/main` niet heeft. `origin/main` heeft alleen de merge-commit van PR #3 extra.
- De lokale branch `main` is 21 commits achter op `origin/main` (`git rev-list --count main..origin/main` gaf 21). Wie lokaal `main` uitcheckt zonder te pullen, ziet oude code.
- Feature branches die **niet** in `origin/dev` zitten:
  - `origin/feature/T-04-qr-tonen`: 3 commits voor, open PR #4
  - `origin/feature/T-06-event-aanmaken`: 7 commits voor (inclusief T-04), open PR #5
  - lokale `feature/T-08-teamrooster`: wijst naar dezelfde 7 commits als T-06, geen eigen T-08-commits
  - T-05, T-09, T-10: geen branch
- Branches die al in `dev` zitten (0 commits voor, alleen achter): T-01, T-02, T-03, T-07, FR-01.
- Werkmap is vuil: gewijzigd `.cursor/rules/cpd.mdc` en `.gitignore`. Untracked: `lib/data/repositories/match_repository.dart` en `lib/features/schedule/` (onafgemaakte T-08).

---

## STAP 2 — Bouwt het?

```
$ flutter pub get
Resolving dependencies...
Downloading packages...
  hooks 2.0.2 (2.1.0 available)
  matcher 0.12.19 (0.12.20 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.0 (1.19.0 available)
  qr 3.0.2 (4.0.0 available)
  record_use 0.6.0 (1.1.0 available)
  test_api 0.7.11 (0.7.13 available)
  vector_math 2.2.0 (2.4.2 available)
Got dependencies!
8 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

Exitcode 0.

```
$ dart format --output=none --set-exit-if-changed .
Could not format because the source could not be parsed:

line 11, column 1 of lib\features\schedule\rooster.dart: The library directive must appear before all other directives.
   ╷
11 │ library;
   │ ^^^^^^^
   ╵
Formatted 33 files (0 changed) in 0.23 seconds.
```

Exitcode 65.

```
$ flutter analyze
Analyzing crossplatformdevelopment...                           

  error - The library directive must appear before all other directives. Try moving the library directive before any other directives - lib\features\schedule\rooster.dart:11:1 - library_directive_not_first
  error - Target of URI doesn't exist: 'rooster_lijst.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist - lib\features\schedule\team_schedule_screen.dart:10:8 - uri_does_not_exist
  error - The name 'LeegRooster' isn't a class. Try correcting the name to match an existing class - lib\features\schedule\team_schedule_screen.dart:118:20 - creation_with_non_type
  error - The method 'RoosterLijst' isn't defined for the type '_Inhoud'. Try correcting the name to the name of an existing method, or defining a method named 'RoosterLijst' - lib\features\schedule\team_schedule_screen.dart:126:12 - undefined_method

4 issues found. (ran in 96.0s)
```

Exitcode 1.

**Uitkomst stap 2:** `pub get` slaagt. Format en analyze falen door **untracked, onafgemaakte T-08-bestanden** in `lib/features/schedule/`. Die horen niet bij de gecommitte `dev`. De gecommitte code op `61d75a9` is eerder schoon geanalyseerd (45 tot 76 tests, analyze zonder issues). Ik heb die T-08-bestanden niet gerepareerd: dat is featurewerk.

`flutter run -d chrome` compileerde wél, omdat `main.dart` `team_schedule_screen.dart` niet importeert. Analyze loopt de hele `lib/`-map na, de webbuild alleen het bereikbare graf.

---

## STAP 3 — Tests

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
00:00 +7: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: login bewaart het token en het gebruikers-id bij een geslaagde poging
00:00 +8: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: login bewaart het token en het gebruikers-id bij een geslaagde poging
00:00 +9: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/auth_repository_test.dart: login bewaart het token en het gebruikers-id bij een geslaagde poging
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
00:00 +27: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: User leest id en naam uit het inlogantwoord
00:00 +28: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leest alle velden, met de leden onder de sleutel members
00:00 +29: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leidt de rol af uit ownerId, want de leden hebben er geen
00:00 +30: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team houdt null in description en metadata leeg
00:00 +31: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team laat ownerId leeg als de API het weglaat
00:00 +32: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest titel, tijden, locatie en team
00:00 +33: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest de tijden als UTC en zet ze om naar lokale tijd
00:00 +34: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event stuurt de tijden als UTC terug naar de API
00:00 +35: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event laat de locatie leeg wanneer die ontbreekt
00:00 +36: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match legt het organiserende team vast in teamId en team
00:00 +37: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match houdt de status per uitnodiging bij, niet op de match zelf
00:00 +38: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match noemt alle betrokken teams, organisator eerst
00:00 +39: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match als geaccepteerd als elke uitnodiging dat is
00:00 +40: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match met een afwijzing niet als geaccepteerd
00:00 +41: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match een match zonder uitnodigingen geldt niet als geaccepteerd
00:00 +42: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest de vorm uit GET /matches/invites, met invite-id
00:00 +43: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest het antwoord op een geaccepteerde uitnodiging
00:00 +44: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite valt terug op pending bij een onbekende status
00:00 +45: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: GeoLocatie leest coördinaten, ook een hele graad zonder decimalen
00:00 +46: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl gebruikt op Android het geo-schema met een pin op de locatie
00:00 +47: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl zet een leesbare plaatsnaam als label bij de pin
00:00 +48: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl laat het label weg wanneer er geen plaatsnaam bekend is
00:00 +49: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl opent op web een Google Maps-route over https
00:00 +50: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl houdt negatieve coördinaten heel op beide platformen
00:00 +51: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl loopt niet stuk op de nulmeridiaan
00:00 +52: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform kiest het geo-schema op een Android-toestel
00:00 +53: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform valt op andere platformen terug op de web-URL
00:00 +54: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute opent de URL die bij het gekozen platform hoort
00:00 +55: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute meldt het wanneer er niets op de URL reageert
00:00 +56: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute valt niet om als er op Android geen kaart-app staat
00:01 +57: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_detail_screen_test.dart: toont titel, team, tijd, locatie en omschrijving
00:02 +58 t/m +62: widget tests login en eventdetail (parallel)
00:02 +63 t/m +75: widget tests teamdetail
00:03 +76: All tests passed!
```

(De regels +58 tot +75 stonden in de ruwe uitvoer met herhaalde testdraadnamen door parallellisatie. De teller eindigde op +76.)

**Exact: 76 tests, 76 geslaagd, 0 gefaald.** Niets hersteld.

Testbestanden op `dev`: `api_client_test`, `auth_repository_test`, `event_repository_test`, `models_test`, `route_starter_test`, `event_detail_screen_test`, `login_screen_test`, `team_detail_screen_test`. Geen tests voor T-04 tot T-10 in de gecommitte suite.

---

## STAP 4 — Draait de app op web?

```
$ flutter run -d chrome
Launching lib\main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...             32.8s

Flutter run key commands.
...
Starting application from main method in: org-dartlang-app:/web_entrypoint.dart.
```

De app startte op `http://localhost:49770/` (later herstart op `http://localhost:50725/`). Titel in Chrome: Teamplanner.

Handmatig, via de echte UI (screenshots + Chrome DevTools), niet via de API namens de UI:

| Handeling | Gelukt? | Wat ik zag |
|---|---|---|
| Registreren met nieuwe naam `verif516217` / `Test12345!` | ja | Scherm Account aanmaken, drie velden gevuld. Daarna bestond de gebruiker op de server: `POST /auth/login` gaf 200, `id` 96. Opnieuw registreren gaf 400. |
| Uitloggen | ja | Van "Mijn teams" terug naar het inlogscherm (titel Teamplanner, knop Inloggen). |
| Opnieuw inloggen | ja | Weer "Mijn teams". Eén teamkaart "test" / "test". Knop "Nieuw team" rechtsonder. |
| Team aanmaken | ja | Dialoog "Nieuw team" met naam `Team verif516217` en beschrijving `Verificatieteam`. Snackbar: `Team "Team verif516217" aangemaakt.` Lijst toont daarna twee kaarten: "test" en "Team verif516217". |

Geen foutmelding in de Flutter-console tijdens deze handelingen. De debug-sessie viel één keer weg na het registreren (Chrome debug-poort 59060 weigerde verbinding). De gebruiker was toen al aangemaakt. De rest is in een nieuwe `flutter run -d chrome` gedaan.

---

## STAP 5 — Draait de app op Android?

```
$ flutter emulators
1 available emulator:

Id       • Name     • Manufacturer • Platform

cpd_test • cpd test • Google       • android
```

```
$ flutter emulators --launch cpd_test
```

Exitcode 0. Daarna:

```
$ adb devices
List of devices attached
emulator-5554	device
```

(`adb` stond niet in PATH. Pad: `C:\Users\pmec\AppData\Local\Android\Sdk\platform-tools\adb.exe`.)

```
$ flutter devices
Found 4 connected devices:
  sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64    • Android 16 (API 36) (emulator)
  Windows (desktop)            • windows       • windows-x64    • Microsoft Windows [Version 10.0.26200.8894]
  Chrome (web)                 • chrome        • web-javascript • Google Chrome 151.0.7922.138
  Edge (web)                   • edge          • web-javascript • Microsoft Edge 151.0.4129.78
```

```
$ flutter run -d emulator-5554
Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
Running Gradle task 'assembleDebug'...
Warning: The plugin flutter_secure_storage requires Android SDK version 37 or higher.
...
Your project is configured to compile against Android SDK 36, but the following plugin(s) require to be compiled against a higher Android SDK version:
- flutter_secure_storage compiles against Android SDK 37
...
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:checkDebugAarMetadata'.
> A failure occurred while executing com.android.build.gradle.internal.tasks.CheckAarMetadataWorkAction
   > An issue was found when checking AAR metadata:

       1.  Dependency ':flutter_secure_storage' requires libraries and applications that
           depend on it to compile against version 37 or later of the
           Android APIs.

           :app is currently compiled against android-36.

           Also, the maximum recommended compile SDK version for Android Gradle
           plugin 9.0.1 is 36.

           Recommended action: Update this project's version of the Android Gradle
           plugin to one that supports 37, then update this project to use
           compileSdk of at least 37.
...
BUILD FAILED in 5m 38s
Running Gradle task 'assembleDebug'...                            340.1s
Error: Gradle task assembleDebug failed with exit code 1
```

**NIET GEDAAN op Android:** registreren, uitloggen, inloggen, team aanmaken. De APK is niet gebouwd. De app is niet op de emulator verschenen.

**`flutter_secure_storage`:** niet op Android gemeten. De build stopt al eerder, juist omdat dit pakket compileSdk 37 eist.

**Netwerkpermissie:** niet op een draaiende app gemeten. Wel in de manifesten gelezen:

- `android/app/src/main/AndroidManifest.xml`: **geen** `INTERNET`-permissie
- `android/app/src/debug/AndroidManifest.xml`: wel `INTERNET` (commentaar: nodig voor de Flutter-tool)
- `android/app/src/profile/AndroidManifest.xml`: wel `INTERNET`

Een debug-build zou dus netwerk mogen (als hij compileerde). Een release-build volgens `src/main` zou dat niet hebben. Dat is niet op een toestel bevestigd.

Ik heb `compileSdk` niet aangepast. Dat is een bugfix, en die was niet gevraagd.

---

## STAP 6 — API

```
$ dart run tool/api_verkenning.dart
```

Exitcode 0. Volledige uitvoer (tokens staan in de ruwe log; hier ingekort tot de kop, omdat het JWT anders in inleverbare documentatie belandt). De ruwe log is lokaal bewaard in de terminal-uitvoer van deze sessie.

```
Running build hooks...Running build hooks...Gebruiker A (beheerder): testuser317814a
Gebruiker B (lid):       testuser317814b
Basis-URL:               https://team-managment-api.dendrowen.com/api/v2

1. POST /auth/register A → 201  data: {id:97, name:testuser317814a}
2. POST /auth/login A → 200  data: {id:97, name:..., token:...}
3. POST /auth/register bestaande naam → 400  error: ["Username already taken"]
4. POST /auth/register B → 201  data: {id:98, name:testuser317814b}
5. POST /auth/login B → 200
6. POST /teams B → 201  team id 309, ownerId 98, members [{id:98,name:...}]
7. POST /teams A → 201  team id 310, ownerId 97
8. GET /teams → 200  lijst van de hele server, afgekapt met "nog 94 item(s)" na 3 voorbeelden
9. GET /teams/310 → 200  volledig team met ownerId en members
10. POST /teams/310/addUser {userId:98} → 200  twee members, geen rolveld per lid
11. GET /teams/310 opnieuw → 200  zelfde twee members
12. POST /events → 201  event id 89, datetimeStart/End met Z en .000, location lat/lng, team ingebed
13. GET /events → 200  alleen het event van dit lidmaatschap (niet de hele server)
14. POST /matches → 201  match id 34, invites[0].status pending, geen status op de match zelf
15. GET /matches/34 → 200  genest team zonder ownerId/description/metadata
16. GET /matches → 200  hele server, afgekapt "nog 21 item(s)"
17. GET /matches/invites als A → 200  data: []
18. GET /matches/invites als B → 200  data: [{id:33, matchId:34, status:pending}]
19. POST /matches/invites/33 {status:accepted} → 200
20. GET /matches/34 na accept → invites[0].status accepted
21. GET /dev/expired-token → 401  error: ["Invalid or expired token"]
22. GET /teams/99999999 → 404  error: ["Team not found"]

Klaar. Uitvoer hoort in docs/api-waargenomen-gedrag.md.
```

Afwijking t.o.v. `docs/api-waargenomen-gedrag.md`: geen andere veldnamen. Wel meer teams (97 i.p.v. ongeveer 94). Onder aan dat bestand is een sectie **Herccontrole 17 augustus 2026** gezet. De bestaande voorbeelden zijn niet herschreven.

---

## STAP 7 — Pull requests

```
$ gh pr list --repo pmecpmec/CPD --state all --limit 30
5	T-06: Event aanmaken (FR-11)	feature/T-06-event-aanmaken	OPEN	2026-08-13T21:50:47Z
4	T-04: QR-uitnodiging tonen (FR-09)	feature/T-04-qr-tonen	OPEN	2026-08-13T21:41:43Z
3	Release: basis van de app naar main	dev	MERGED	2026-08-13T21:38:00Z
2	T-03 Teamdetail ...	feature/T-03-teamdetail	MERGED	2026-08-12T13:30:01Z
1	FR-01 Foutmelding ...	fix/foutveld-api-client	MERGED	2026-08-12T13:21:55Z
```

Per PR, hoe het in `dev` of `main` terechtkwam:

| PR | Doel | Staat | Via pull request gemerged? |
|---|---|---|---|
| #1 FR-01 | `dev` | MERGED 12 aug, merge-commit `bfe885f` | Ja, GitHub-PR, gemerged door `pmecpmec`. Er is daarnaast lokaal ook `git merge --no-ff origin/fix/foutveld-api-client` gedaan. Dezelfde commit. |
| #2 T-03 | `dev` | MERGED 12 aug, merge-commit `37e5b23` | Ja, GitHub-PR. Zelfde merge-commit als de lokale `Merge T-03`. |
| #3 Release | `main` | MERGED 13 aug, merge-commit `c828f08` | Ja, GitHub-PR van `dev` naar `main`. |
| #4 T-04 | `dev` | OPEN | Nee, niet gemerged. |
| #5 T-06 | `dev` | OPEN | Nee, niet gemerged. |

**Rechtstreeks naar `dev` gemerged, zonder eigen GitHub-PR:**

- T-01: lokale merge `e364960 Merge T-01...` (branch was wel gepusht)
- T-02: lokale merge `848d261 Merge T-02...`
- T-07: lokale merge `6b4e104 Merge T-07...`

Die drie staan wel in de geschiedenis van PR #3 naar `main`, maar hadden geen eigen PR naar `dev`.

**Branch protection**

```
$ gh api repos/pmecpmec/CPD/branches/main/protection
{"message":"Upgrade to GitHub Pro or make this repository public to enable this feature.","status":"403"}

$ gh api repos/pmecpmec/CPD/branches/dev/protection
{"message":"Upgrade to GitHub Pro or make this repository public to enable this feature.","status":"403"}
```

`main` is **niet** beschermd met een branch protection rule. Het gratis plan op een private repo biedt die functie niet. Iedereen met schrijfrechten kan rechtstreeks naar `main` pushen.

---

## STAP 8 — Merge naar main

Geprobeerd:

```
$ gh pr create --repo pmecpmec/CPD --base main --head dev --title "..."
pull request create failed: GraphQL: No commits between main and dev (createPullRequest)
```

**Niet opnieuw gemerged.** `origin/main` bevat `origin/dev` al via PR #3 (`c828f08`). Er is niets nieuws om te mergen. Daardoor is er ook geen nieuwe Actions-run gestart.

Bestaande runs op `main` na PR #3:

| Workflow | Run | Status | URL |
|---|---|---|---|
| CI | 31746582056 | failure | https://github.com/pmecpmec/CPD/actions/runs/31746582056 |
| Deploy | 31746582035 | failure | https://github.com/pmecpmec/CPD/actions/runs/31746582035 |

CI-jobs: Analyse en test **success**, Webbuild **success**, Androidbuild **failure** (`flutter_secure_storage` eist compileSdk 37, app staat op 36).

Deploy-jobs: Webversie bouwen **failure**, Publiceren **skipped**. De Flutter-webbuild zelf slaagde (`✓ Built build/web`). Daarna:

```
##[error]Get Pages site failed. Please verify that the repository has Pages enabled and configured to build using GitHub Actions
Error: Not Found
```

Oorzaak (al eerder gemeten): private repo op het gratis GitHub-plan, Pages niet beschikbaar. Er staat geen app online.

---

## 5. Handmatig getest (sjabloon)

| Platform | Getest? | Wat ik heb gedaan | Wat er gebeurde |
|---|---|---|---|
| Web (`flutter run -d chrome`) | ja | registreren, uitloggen, inloggen, team aanmaken | alle vier gelukt, zie stap 4 |
| Android (emulator `cpd_test`) | nee | emulator gestart, `flutter run -d emulator-5554` | build faalt, zie stap 5 |

## 7. Wat ik NIET heb gedaan

- T-08/T-09/T-04/T-05/T-06/T-10 niet afgebouwd of gemerged
- Android-app niet gedraaid, `flutter_secure_storage` niet op Android gemeten
- `compileSdk` niet naar 37 gezet
- Geen nieuwe merge naar `main` (geen commits tussen de branches)
- Untracked T-08-bestanden niet opgeruimd en niet afgemaakt
- Helper-scripts voor Chrome DevTools niet in de repo gezet (tijdelijk in `%TEMP%\cpd-webdrive`)

## 10. Aannames

Geen aanname over Android-gedrag. Alleen wat de Gradle-fout en de manifesten zeggen.

## 11. Git (deze verificatie)

Branch: `dev` (`61d75a9`). Dit rapport en de hercontrole in `docs/api-waargenomen-gedrag.md` staan lokaal, niet gecommit, tenzij Pedro dat daarna doet.

---

## Sluiting (één zin per stap)

1. Git: op GitHub loopt `main` niet achter op `dev`; lokaal `main` wel; T-04 en T-06 hebben open PR's, T-08 tot T-10 zitten niet in `dev`.
2. Bouwen: `pub get` slaagt, format en analyze falen op onafgemaakte untracked T-08-bestanden.
3. Tests: 76 geslaagd, 0 gefaald, niets hersteld.
4. Web: app draait; registreren, uitloggen, inloggen en team aanmaken zijn in de UI gelukt.
5. Android: emulator start, build faalt op compileSdk 36 vs 37 van `flutter_secure_storage`; app niet gedraaid.
6. API: verkenningsscript slaagt, veldnamen ongewijzigd, hercontrole toegevoegd aan `docs/api-waargenomen-gedrag.md`.
7. PR's: #1 #2 #3 via GitHub gemerged; T-01 T-02 T-07 rechtstreeks naar `dev`; `main` heeft geen branch protection.
8. Merge naar `main`: geen commits tussen de branches, dus geen nieuwe PR; CI en Deploy van PR #3 blijven rood.
