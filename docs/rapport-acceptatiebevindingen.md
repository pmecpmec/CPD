# Rapport — Acceptatiebevindingen (drie bugfixes)

Vul dit sjabloon volledig in. Kopieer het naar `docs/rapport-T-XX.md` en vervang XX door het taaknummer.
Laat geen veld leeg. Weet je iets niet, schrijf dan letterlijk `NIET GEDAAN` of `WEET IK NIET`.

Verzin niets. Als een stap niet is uitgevoerd, schrijf dan dat hij niet is uitgevoerd. Een eerlijk rapport met
drie mislukte stappen is bruikbaar. Een rapport dat succes meldt terwijl er iets niet is gedaan, is schadelijk,
want er wordt documentatie op gebaseerd die daarna niet klopt.

---

## 1. Wat er gevraagd was

Taaknummer: acceptatiebevindingen (geen T-nummer)
Requirements: FR-14, FR-01, NFR-03
Branch: `fix/acceptatietest-bevindingen`

Drie kleine bugfixes, geen nieuwe features:

1. Agenda ververst nooit: `IndexedStack` in `HomeShell` houdt `MyScheduleScreen` in leven, dus `initState` draait één keer. Bij openen van het tabblad Agenda opnieuw `laad()` aanroepen, op NavigationBar en NavigationRail.
2. Foutmelding blijft staan: `wisFout()` bij sluiten van registreren, niet alleen bij openen. AppBar-terug en systeem-terug.
3. Serverfouten Engels: alleen vier bekende teksten vertalen. Onbekende teksten blijven staan.

`home_shell.dart` ontbreekt op `origin/dev`. De branch is daarom vanaf `origin/feature/T-08-T-09-roosters` (PR #9) gemaakt, niet vanaf `origin/dev`. T-08/T-09 is verder niet gewijzigd.

QR-scan, matches, `match_repository.dart` en de scan-knop in `teams_screen.dart` zijn niet aangeraakt.

---

## 2. Bestanden

Nieuw aangemaakt:
- `test/widget/home_shell_test.dart` — testdubbel telt `laad()` bij wissel naar Agenda, op smal en breed scherm
- `test/unit/errors_test.dart` — vier bekende vertalingen plus één onbekende tekst
- `docs/advies-foutmeldingen-nederlands.md` — keuze voor een vaste lijst in `errors.dart`
- `docs/rapport-acceptatiebevindingen.md` — dit rapport

Gewijzigd:
- `lib/features/teams/home_shell.dart` — `_kiesBestemming` roept `MyScheduleController.laad()` aan als index 1 (Agenda) is, voor rail en balk
- `lib/features/auth/register_screen.dart` — `PopScope` met `canPop: false` wist de fout vóór `pop`, zodat AppBar-terug en systeem-terug dezelfde weg nemen
- `test/widget/register_screen_test.dart` — twee tests: AppBar-terug en systeem-terug
- `lib/core/errors.dart` — functie `vertaalServerFout`
- `lib/data/api/api_client.dart` — vertaling bij het lezen van het foutveld; 404 gebruikt nu ook de servermelding
- `test/unit/api_client_test.dart` — verwachte teksten voor de vier bekende meldingen
- `test/unit/auth_repository_test.dart` — verwachte tekst bij `Username already taken`

Verwijderd:
-

---

## 3. Commando's die ik heb gedraaid

Na elke fix: `dart format lib test && flutter analyze && flutter test`.
Hieronder de laatste run, na alle drie de fixes.

```
$ flutter analyze
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
Analyzing acceptatie-fix...
No issues found! (ran in 3.0s)
```

```
$ flutter test
00:00 +0: loading test/unit/api_client_test.dart
... (123 tests, zie tabel in §4) ...
00:17 +123: All tests passed!
```

De volledige testrun eindigde op `+123: All tests passed!`. Geen enkele test is gefaald.
Nieuwe tests die in de log staan:
- `test/unit/errors_test.dart`: vijf tests (vier bekende + één onbekende)
- `test/widget/home_shell_test.dart`: NavigationBar en NavigationRail
- `test/widget/register_screen_test.dart`: AppBar-terug en systeem-terug

```
$ dart format .
Formatted 53 files (0 changed) in 0.64 seconds.
```

---

## 4. Tests

| Testbestand | Aantal tests | Geslaagd | Gefaald |
|---|---|---|---|
| test/unit/api_client_test.dart | 10 | 10 | 0 |
| test/unit/auth_repository_test.dart | 7 | 7 | 0 |
| test/unit/errors_test.dart | 5 | 5 | 0 |
| test/unit/event_repository_test.dart | 10 | 10 | 0 |
| test/unit/match_repository_test.dart | 5 | 5 | 0 |
| test/unit/models_test.dart | 19 | 19 | 0 |
| test/unit/persoonlijk_rooster_test.dart | 3 | 3 | 0 |
| test/unit/route_starter_test.dart | 11 | 11 | 0 |
| test/unit/schedule_sortering_test.dart | 10 | 10 | 0 |
| test/unit/teams_controller_test.dart | 2 | 2 | 0 |
| test/unit/team_uitnodiging_test.dart | 4 | 4 | 0 |
| test/widget/event_detail_screen_test.dart | 6 | 6 | 0 |
| test/widget/event_form_screen_test.dart | 9 | 9 | 0 |
| test/widget/home_shell_test.dart | 2 | 2 | 0 |
| test/widget/login_screen_test.dart | 5 | 5 | 0 |
| test/widget/qr_invite_dialog_test.dart | 2 | 2 | 0 |
| test/widget/register_screen_test.dart | 3 | 3 | 0 |
| test/widget/teams_screen_test.dart | 1 | 1 | 0 |
| test/widget/team_detail_screen_test.dart | 9 | 9 | 0 |
| Totaal | 123 | 123 | 0 |

Welk requirement dekt elke test? Alleen de tests van deze taak:

- `home_shell_test`: NavigationBar laadt de agenda opnieuw (FR-14)
- `home_shell_test`: NavigationRail laadt de agenda opnieuw (FR-14)
- `register_screen_test`: AppBar-terug wist de foutmelding (FR-01)
- `register_screen_test`: systeem-terug wist de foutmelding (FR-01)
- `errors_test`: Username already taken (NFR-03)
- `errors_test`: Invalid username or password (NFR-03)
- `errors_test`: Team not found (NFR-03)
- `errors_test`: Invalid or expired token (NFR-03)
- `errors_test`: onbekende melding blijft onvertaald (NFR-03)

De bestaande test `validatiemelding verdwijnt...` in `register_screen_test` dekt FR-01 (clientvalidatie) en is niet nieuw.

---

## 5. Handmatig getest

| Platform | Getest? | Wat ik heb gedaan | Wat er gebeurde |
|---|---|---|---|
| Web (`flutter run -d chrome`) | nee | NIET GEDAAN | NIET GEDAAN |
| Android (emulator of toestel) | nee | NIET GEDAAN | NIET GEDAAN |

Heb je het niet handmatig gedraaid, schrijf dan `NIET GEDAAN` en waarom.

NIET GEDAAN. Deze sessie heeft alleen `flutter analyze` en `flutter test` gedraaid. Er is geen Chrome-run en geen emulator-run gedaan. De widgettests dekken de tabwissel en het sluiten van registreren. De drie bevindingen zelf zijn niet opnieuw in de draaiende app nagelopen.

---

## 6. Acceptatiecriteria uit de taak

| Criterium (letterlijk uit de taak) | Gehaald? | Hoe vastgesteld |
|---|---|---|
| IndexedStack in home_shell.dart: MyScheduleScreen.initState één keer. Bij onDestinationSelected opnieuw laad() als de gebruiker naar Agenda gaat. NavigationRail EN NavigationBar. | ja | `_kiesBestemming` op beide navigatiewidgets. Widgettests op 390 px (balk) en 900 px (rail). |
| Widget test: HomeShell met testdubbel, naar Agenda, bewijs dat laad() is aangeroepen. | ja | `test/widget/home_shell_test.dart`: teller stijgt met 1 na tik op Agenda. |
| wisFout() bij sluiten van registreren (niet alleen bij openen). AppBar-terug en systeem-terug. | ja | `PopScope` + `_sluit()`. Twee widgettests. |
| ALLEEN deze vertalingen: de vier genoemde teksten. Onbekend: onvertaald. | ja | `vertaalServerFout` in `errors.dart`. |
| Unit test: vier bekende + één onbekende. | ja | `test/unit/errors_test.dart`, vijf tests, allemaal groen. |
| docs/rapport-acceptatiebevindingen.md volgens sjabloon. | ja | Dit bestand. |
| Push. PR naar dev met gh. | nee | Nog niet gedaan op het moment van dit rapport. Volgt in dezelfde sessie. |

---

## 7. Wat ik NIET heb gedaan

- Handmatig draaien op web en Android. Alleen analyze en de testsuite.
- T-08/T-09 verder wijzigen. Alleen `home_shell.dart` voor de agenda-fix, zoals gevraagd.
- QR-scan, matches, `match_repository.dart` en een scan-knop in `teams_screen.dart`. Die hoorden bij een andere agent.
- Andere serverteksten vertalen dan de vier genoemde.
- `MyScheduleScreen.initState` weghalen. Die blijft de eerste `laad()` doen. De tabwissel doet de tweede.

---

## 8. Keuzes die ik heb gemaakt

| Keuze | Alternatief | Reden |
|---|---|---|
| Branch vanaf `origin/feature/T-08-T-09-roosters` | Vanaf `origin/dev` | `home_shell.dart` staat niet op `origin/dev`. De taak zei dan af te splitsen van T-08/T-09. |
| Worktree `worktrees/acceptatie-fix` | Werken in de hoofd-repo op T-08-T-09 | De hoofd-repo stond op die featurebranch. Een worktree voorkomt botsing met T-05. |
| `PopScope(canPop: false)` en daarna zelf `pop` | `canPop: true` en wissen ná de pop | Na een echte pop is `RegisterScreen` al weg. `context.read` is dan onveilig. Wissen gebeurt nu vóór `pop`. |
| Vertaling in `errors.dart`, aanroep in `ApiClient` | Alleen in de schermen, of een vertaalpakket | Eén functie, herbruikbaar. Schermen mogen geen eigen foutteksten verzinnen. Meertaligheid is Won't have. |
| 404 gebruikt de servermelding | 404 blijft `const NietGevondenException()` | `GET /teams/{id}` geeft 404 met `"Team not found"`. Zonder deze stap bereikt die vertaling de gebruiker niet. |

---

## 9. Waar ik tegenaan liep

- `origin/dev` heeft geen `home_shell.dart`. Zonder T-08/T-09 als basis is de agenda-fix niet te plaatsen.
- `flutter pub get` in de worktree zette generated plugin-bestanden op Linux/macOS/Windows als gewijzigd (regelendings). Die zijn niet meegenomen in commits.
- De testdubbel voor `HomeShell` heeft stubs voor teams, events, matches en auth nodig, omdat `TeamsScreen` en `MyScheduleScreen` allebei in de `IndexedStack` staan. `laad()` van de agenda is overschreven zodat de test alleen de teller ziet.

---

## 10. Aannames

- Index 1 is Agenda. Dat volgt uit de volgorde in `HomeShell`: Teams, dan Agenda.
- `handlePopRoute` in de widgettest is dezelfde weg als de Android-terugknop.
- De PR naar `dev` mag de T-08/T-09-commits meenemen zolang PR #9 nog niet gemerged is. Na merge van #9 blijven alleen de fix-commits over.

---

## 11. Git

Branch: `fix/acceptatietest-bevindingen`
Commits (`git log --oneline` van deze branch ten opzichte van T-08-T-09):
```
2bf831b fix: bekende API-foutmeldingen in het Nederlands
5d85b3d fix: foutmelding wissen bij sluiten van registreren
61fd853 fix: agenda opnieuw laden bij openen van het tabblad
```
(plus deze documentatie-commit na het schrijven van het rapport)

Pull request aangemaakt: nee
Gemerged naar `dev`: nee

---

## 12. Voor de volgende taak

- Deze PR hangt inhoudelijk van T-08/T-09 af. Merge PR #9 naar `dev` eerst, of merge deze PR als die de rooster-commits mag meenemen.
- Agenda laadt nu bij élke tik op het tabblad, ook als je er al op staat (als `onDestinationSelected` dan nog vuurt).
- Onbekende Engelse serverteksten blijven Engels. Nieuwe teksten van de API horen in `vertaalServerFout` als ze in beeld mogen.
- Handmatige check op web en Android van de drie bevindingen is nog open.
