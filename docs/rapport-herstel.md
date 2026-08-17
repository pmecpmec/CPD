# Rapport herstel na verificatie

Vul dit sjabloon volledig in. Kopieer het naar `docs/rapport-T-XX.md` en vervang XX door het taaknummer.
Laat geen veld leeg. Weet je iets niet, schrijf dan letterlijk `NIET GEDAAN` of `WEET IK NIET`.

Verzin niets. Als een stap niet is uitgevoerd, schrijf dan dat hij niet is uitgevoerd. Een eerlijk rapport met
drie mislukte stappen is bruikbaar. Een rapport dat succes meldt terwijl er iets niet is gedaan, is schadelijk,
want er wordt documentatie op gebaseerd die daarna niet klopt.

---

## 1. Wat er gevraagd was

Taaknummer: herstel na verificatie (geen T-nummer)
Requirements: FR-01 (registreren), FR-02 (inloggen), FR-03 (sessie), FR-04 (team aanmaken), NFR-03 (foutteksten uit validators), NFR-06 (testdubbels)
Branch: `fix/verificatie-herstel`

Vier stappen, in deze volgorde:
1. Android-build repareren: `compileSdk` 37, daarna `flutter run` op emulator-5554, handmatig registreren, inloggen, herstarten, team aanmaken
2. INTERNET-permissie in het hoofdmanifest
3. `autovalidateMode: AutovalidateMode.onUserInteraction` op drie Form-widgets, plus widget tests
4. Onafgewerkte T-08-bestanden parkeren, herstel-PR mergen, daarna PR #4 en PR #5 mergen

## 2. Bestanden

Nieuw aangemaakt:
- `test/widget/register_screen_test.dart`: bewijst dat de validatiemelding op registreren verdwijnt bij geldige invoer
- `test/widget/teams_screen_test.dart`: opent de nieuw-teamdialoog en bewijst hetzelfde voor de teamnaam
- `docs/rapport-herstel.md`: dit rapport

Gewijzigd:
- `android/app/build.gradle.kts`: `compileSdk` vastgezet op 37 in plaats van `flutter.compileSdkVersion`, zodat `flutter_secure_storage` bouwt
- `android/app/src/main/AndroidManifest.xml`: INTERNET-permissie toegevoegd als sibling van `<application>`
- `lib/features/auth/login_screen.dart`: `autovalidateMode` op de Form
- `lib/features/auth/register_screen.dart`: `autovalidateMode` op de Form
- `lib/features/teams/teams_screen.dart`: `autovalidateMode` op de Form in `_NieuwTeamDialoog`
- `test/widget/login_screen_test.dart`: extra widget test voor het verdwijnen van de validatiemelding

Verwijderd:
- Niets uit git. De onafgewerkte T-08-bestanden stonden untracked in de werkmap. Die zijn verplaatst naar buiten het project, zie hoofdstuk 7.

## 3. Commando's die ik heb gedraaid

`dart format .` faalde door een kapot pad onder `build/` (Gradle-output van flutter_secure_storage). Dat pad hoort niet bij de broncode. Daarna `dart format lib test` gedraaid. CI formatteert bronbestanden, niet `build/`.

```
$ dart format .
PathNotFoundException: Directory listing failed, path = '.\build\flutter_secure_storage\.transforms\29117025c3bb6727ff9ce036eeb1a61e\transformed\bundleLibRuntimeToDirDebug\bundleLibRuntimeToDirDebug_global-synthetics\com\it_nomads\fluttersecurestorage\ciphers\*' (OS Error: The system cannot find the path specified, errno = 3)
```

```
$ dart format lib test
Formatted 37 files (0 changed) in 0.44 seconds.
```

Na stap 1 tot en met 3 (herstelbranch, vóór merge van T-04 en T-06):

```
$ flutter analyze
Analyzing crossplatformdevelopment...
No issues found! (ran in 4.4s)
```

Na stap 4, op `dev` ná merge van PR #6, #4 en #5:

```
$ flutter analyze
Analyzing crossplatformdevelopment...
No issues found! (ran in 9.8s)
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
00:01 +17: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents haalt de events van alle teams van de gebruiker op
00:01 +18: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents geeft een lege lijst terug wanneer er niets gepland is
00:01 +19: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvents geeft een lege lijst terug bij een onverwacht antwoord
00:01 +20: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvent leest één event op id
00:01 +21: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: haalEvent meldt het wanneer het event niet bestaat
00:01 +22: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent verstuurt titel, tijden in UTC en een coördinatenpaar
00:01 +23: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent laat de locatie weg wanneer die niet is opgegeven
00:01 +24: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: maakEvent geeft een GeenRechtenException als een lid geen event mag maken
00:01 +25: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: wijzigEvent en verwijderEvent stuurt een PUT naar het event zonder teamId mee te sturen
00:01 +26: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/event_repository_test.dart: wijzigEvent en verwijderEvent stuurt een DELETE naar het event
00:01 +27: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: User leest id en naam uit het inlogantwoord
00:01 +28: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leest alle velden, met de leden onder de sleutel members
00:01 +29: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team leidt de rol af uit ownerId, want de leden hebben er geen
00:01 +30: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team houdt null in description en metadata leeg
00:01 +31: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Team laat ownerId leeg als de API het weglaat
00:01 +32: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest titel, tijden, locatie en team
00:01 +33: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event leest de tijden als UTC en zet ze om naar lokale tijd
00:01 +34: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event stuurt de tijden als UTC terug naar de API
00:01 +35: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Event laat de locatie leeg wanneer die ontbreekt
00:01 +36: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match legt het organiserende team vast in teamId en team
00:02 +37: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match houdt de status per uitnodiging bij, niet op de match zelf
00:02 +38: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match noemt alle betrokken teams, organisator eerst
00:02 +39: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match als geaccepteerd als elke uitnodiging dat is
00:02 +40: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match ziet een match met een afwijzing niet als geaccepteerd
00:02 +41: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: Match een match zonder uitnodigingen geldt niet als geaccepteerd
00:02 +42: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest de vorm uit GET /matches/invites, met invite-id
00:02 +43: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite leest het antwoord op een geaccepteerde uitnodiging
00:02 +44: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: MatchInvite valt terug op pending bij een onbekende status
00:02 +45: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/models_test.dart: GeoLocatie leest coördinaten, ook een hele graad zonder decimalen
00:02 +46: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl gebruikt op Android het geo-schema met een pin op de locatie
00:02 +47: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl zet een leesbare plaatsnaam als label bij de pin
00:02 +48: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl laat het label weg wanneer er geen plaatsnaam bekend is
00:02 +49: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl opent op web een Google Maps-route over https
00:02 +50: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl houdt negatieve coördinaten heel op beide platformen
00:02 +51: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: bouwKaartUrl loopt niet stuk op de nulmeridiaan
00:02 +52: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform kiest het geo-schema op een Android-toestel
00:02 +53: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: huidigKaartPlatform valt op andere platformen terug op de web-URL
00:02 +54: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute opent de URL die bij het gekozen platform hoort
00:02 +55: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute meldt het wanneer er niets op de URL reageert
00:02 +56: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/route_starter_test.dart: startRoute valt niet om als er op Android geen kaart-app staat
00:02 +57: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode heeft de afgesproken vorm en bevat het team-id
00:02 +58: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode begint met het voorvoegsel en eindigt op het team-id
00:02 +59: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode geeft elk team een eigen code
00:02 +60: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/unit/team_uitnodiging_test.dart: TeamUitnodiging.bouwCode een gebouwde code is weer terug te lezen
00:03 +61: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_detail_screen_test.dart: toont titel, team, tijd, locatie en omschrijving
00:05 +62: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:05 +63: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:06 +64: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:06 +65: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:07 +66: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:07 +67: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:07 +68: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:08 +69: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lege titel wordt geweigerd
00:08 +70: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:08 +71: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:08 +72: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:09 +73: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:09 +74: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/register_screen_test.dart: validatiemelding verdwijnt zodra er geldige tekst wordt ingevoerd
00:09 +75: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:09 +76: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:09 +77: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:10 +78: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:10 +79: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:10 +80: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:11 +81: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:11 +82: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/teams_screen_test.dart: validatiemelding in de nieuw-teamdialoog verdwijnt bij geldige invoer
00:11 +83: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lengtegraad buiten het bereik wordt geweigerd
00:11 +84: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lengtegraad buiten het bereik wordt geweigerd
00:11 +85: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: validatie vóór verzending (FR-11) een lengtegraad buiten het bereik wordt geweigerd
00:11 +86: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) verlaten vraagt eerst om bevestiging en sluit dan het scherm
00:12 +87: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) verlaten vraagt eerst om bevestiging en sluit dan het scherm
00:12 +88: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden stuurt titel, periode, coördinaten en plaatsnaam mee
00:13 +89: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert een lid na bevestiging
00:13 +90: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden een event zonder coördinaten krijgt geen locatie
00:13 +91: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/team_detail_screen_test.dart: acties (FR-07, FR-08) de beheerder verwijdert het team na bevestiging
00:13 +92: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden toont de melding uit errors.dart als de server weigert
00:13 +93: C:/Users/pmec/Documents/School/CPD/crossplatformdevelopment/test/widget/event_form_screen_test.dart: verzenden toont de melding uit errors.dart als de server weigert
00:14 +94: All tests passed!
```

Na stap 3 (vóór merge van T-04 en T-06) gaf `flutter test` `00:09 +79: All tests passed!`.

Eerste `flutter run -d emulator-5554` faalde niet op compileSdk. Die faalde op CMake:

```
Execution failed for task ':app:configureCMakeDebug[arm64-v8a]'.
> com.android.builder.sdk.InstallFailedException: Failed to install the following SDK components:
      cmake;3.22.1 CMake 3.22.1
  Install the missing components using the SDK manager in Android Studio.
```

Oorzaak: `java.net.SocketException: Connection reset` tijdens het downloaden van CMake 3.22.1. CMake is daarna geïnstalleerd met `sdkmanager.bat "cmake;3.22.1"`. Tweede `flutter run -d emulator-5554` slaagde: `√ Built build\app\outputs\flutter-apk\app-debug.apk`. De Android Gradle plugin-versie is niet gewijzigd. De foutmelding vroeg daar niet om.

## 4. Tests

| Testbestand | Aantal tests | Geslaagd | Gefaald |
|---|---|---|---|
| `test/unit/api_client_test.dart` | 10 | 10 | 0 |
| `test/unit/auth_repository_test.dart` | 7 | 7 | 0 |
| `test/unit/event_repository_test.dart` | 10 | 10 | 0 |
| `test/unit/models_test.dart` | 19 | 19 | 0 |
| `test/unit/route_starter_test.dart` | 11 | 11 | 0 |
| `test/unit/team_uitnodiging_test.dart` | 4 | 4 | 0 |
| `test/widget/event_detail_screen_test.dart` | 6 | 6 | 0 |
| `test/widget/event_form_screen_test.dart` | 9 | 9 | 0 |
| `test/widget/login_screen_test.dart` | 5 | 5 | 0 |
| `test/widget/qr_invite_dialog_test.dart` | 2 | 2 | 0 |
| `test/widget/register_screen_test.dart` | 1 | 1 | 0 |
| `test/widget/team_detail_screen_test.dart` | 9 | 9 | 0 |
| `test/widget/teams_screen_test.dart` | 1 | 1 | 0 |
| Totaal na merge | 94 | 94 | 0 |

Welk requirement dekt elke test? Noem per test het FR- of NFR-nummer.

Nieuw in deze taak:
- `login_screen_test` validatiemelding verdwijnt: FR-02, NFR-03
- `register_screen_test` validatiemelding verdwijnt: FR-01, NFR-03
- `teams_screen_test` validatiemelding in de nieuw-teamdialoog: FR-04, NFR-03

Bestaande tests zijn niet van deze taak. Die dekken FR-01 tot FR-12, FR-17, NFR-03, NFR-06 zoals in hun eigen rapporten.

## 5. Handmatig getest

| Platform | Getest? | Wat ik heb gedaan | Wat er gebeurde |
|---|---|---|---|
| Web (`flutter run -d chrome`) | nee | NIET GEDAAN | Deze taak vroeg om Android. Web is niet gedraaid. |
| Android (emulator of toestel) | ja | emulator-5554 (`cpd_test`), app gebouwd en handmatig bediend | Zie de handelingen hieronder. |

Emulator: `emulator-5554` (sdk gphone64 x86 64). Die draaide al. Testaccount: `hr17014445`, wachtwoord `geheim123`.

Registreren:
- Eerste poging mislukte. `adb input text` zette naam en wachtwoord achter elkaar in het naamveld. De API antwoordde `Username already taken` op die samengevoegde string.
- Tweede poging: velden één voor één ingevuld. Naam `hr17014445`, wachtwoord twee keer `geheim123`. Knop Account aanmaken. Daarna scherm Mijn teams met lege staat. Registreren is gelukt. De app logt na registreren meteen in.

Inloggen:
- Uitgelogd via het icoon rechtsboven. Login scherm verscheen.
- Naam `hr17014445` en wachtwoord `geheim123` ingevuld. Knop Inloggen. Daarna Mijn teams met team Herstelteam. Inloggen is gelukt.

App sluiten en opnieuw openen:
- `adb shell am force-stop com.example.crossplatformdevelopment`
- `adb shell am start -n com.example.crossplatformdevelopment/.MainActivity`
- Eerst Flutter splash, daarna Mijn teams zonder opnieuw in te loggen. `flutter_secure_storage` bewaart de sessie. `flutter run` verloor hier de verbinding (verwacht na force-stop). De app startte daarna zelfstandig.

Team aanmaken:
- Knop Nieuw team. Naam `Herstelteam`, beschrijving `Testdesc`. Knop Aanmaken.
- Snackbar: `Team "Herstelteam" aangemaakt.` De lijst toont de kaart Herstelteam / Testdesc.

## 6. Acceptatiecriteria uit de taak

| Criterium (letterlijk uit de taak) | Gehaald? | Hoe vastgesteld |
|---|---|---|
| Zet in `android/app/build.gradle.kts` `compileSdk` expliciet op 37 in plaats van `flutter.compileSdkVersion` | ja | Diff in dat bestand. `flutter run` bouwde daarna `app-debug.apk`. |
| Draai daarna: `flutter run -d emulator-5554` | ja | Tweede poging slaagde na CMake-installatie. Eerste poging faalde op CMake-download, niet op compileSdk. |
| Test in de app: registreren (nieuwe unieke naam) | ja | Account `hr17014445` aangemaakt. Scherm ging naar Mijn teams. |
| Test in de app: inloggen | ja | Uitgelogd en opnieuw ingelogd met hetzelfde account. Mijn teams verscheen. |
| Test in de app: app sluiten en opnieuw openen (sessie via flutter_secure_storage) | ja | force-stop en am start. Mijn teams zonder inlogscherm. |
| Test in de app: team aanmaken | ja | Team Herstelteam in de lijst plus snackbar. |
| Voeg INTERNET-permissie toe aan main, als sibling van `<application>` | ja | Regel staat in `android/app/src/main/AndroidManifest.xml` buiten `<application>`. |
| Zet op alle drie de Form-widgets `autovalidateMode: AutovalidateMode.onUserInteraction` | ja | login, register, `_NieuwTeamDialoog`. |
| Voeg per scherm een widget test toe die bewijst dat de melding verdwijnt zodra er geldige tekst wordt ingevoerd | ja | Drie tests, alle groen. |
| T-08 NIET afbouwen. Verplaats die map (en match_repository) tijdelijk buiten het project | ja | Bestanden staan in `C:\Users\pmec\Documents\School\CPD\_t08-parkeren\`. |
| Eerst herstel-commits pushen en PR naar `dev` maken | ja | PR #6, https://github.com/pmecpmec/CPD/pull/6 |
| Merge die herstel-PR naar `dev` | ja | PR #6 MERGED op 2026-08-17T00:56:24Z |
| Daarna PR #4 en #5 mergen | ja | #4 MERGED 00:56:39Z, #5 MERGED 00:56:42Z. Geen conflicten. |
| `flutter analyze` moet "No issues found" geven | ja | Na herstel en na merge van T-04/T-06. |
| `flutter test` groen | ja | 79 tests na stap 3, 94 tests na merge van T-04/T-06. |
| Schrijf `docs/rapport-herstel.md` volgens het sjabloon | ja | Dit bestand. |

## 7. Wat ik NIET heb gedaan

- T-08 niet afgemaakt. Dat was de opdracht. De bestanden zijn alleen verplaatst.
- Web niet handmatig getest. De taak vroeg om Android.
- `dart format .` over de hele boom inclusief `build/` is niet groen. `dart format lib test` wel.
- Android Gradle plugin niet verhoogd. De foutmelding vroeg om CMake, niet om AGP.
- T-08-bestanden zijn eerder verplaatst dan stap 4 in de tekst. Zonder die verplaatsing compileert `flutter run` niet: `rooster.dart` heeft een ongeldige `library;`-directive en `rooster_lijst.dart` ontbreekt.

T-08 staat hier:

```
C:\Users\pmec\Documents\School\CPD\_t08-parkeren\lib\features\schedule\rooster.dart
C:\Users\pmec\Documents\School\CPD\_t08-parkeren\lib\features\schedule\team_schedule_controller.dart
C:\Users\pmec\Documents\School\CPD\_t08-parkeren\lib\features\schedule\team_schedule_screen.dart
C:\Users\pmec\Documents\School\CPD\_t08-parkeren\lib\data\repositories\match_repository.dart
```

## 8. Keuzes die ik heb gemaakt

| Keuze | Alternatief | Reden |
|---|---|---|
| CMake 3.22.1 via sdkmanager installeren | Wachten tot Gradle het zelf opnieuw downloadt, of stoppen | De foutmelding zei letterlijk die component te installeren. compileSdk 37 was al gezet. Nog eens dezelfde download laten falen lost niets op. |
| T-08 verplaatsen vóór de eerste `flutter run` | Wachten tot stap 4 | De untracked T-08-bestanden zitten in `lib/` en laten de Dart-compile falen. Zonder verplaatsen start de app niet. |
| `dart format lib test` in plaats van `dart format .` | Format over `build/` forceren | `.` loopt vast op een ontbrekend Gradle-pad. Broncode is `lib` en `test`. |
| PR #4 mergen, daarna PR #5 | Alleen #5 mergen en #4 sluiten | T-06 bevat de drie T-04-commits al. De taak stond beide volgordes toe. Eerst #4, dan #5, gaf geen conflicten. |
| Rapport als extra commit ná merge van PR #6 | Rapport in dezelfde PR stoppen vóór de merge | De merge van #4 en #5 moest in het rapport. Die feiten bestonden pas ná de merge. |

## 9. Waar ik tegenaan liep

- Eerste Android-build: CMake 3.22.1 download met connection reset. compileSdk 37 was niet de blokkade op dat moment.
- Waarschuwing: package id `platforms;android-37.0` in map `platforms\android-37`. Dat was een waarschuwing, geen buildfout.
- Stylus-overlay "Try out your stylus" lag over de app. Weggeklikt met BACK. Daarna was het registratiescherm zichtbaar.
- `adb input text` plakte bij de eerste registratie alles in één veld. Daarna velden één voor één, met toetsenbord wegklappen ertussen.
- `adb exec-out screencap` via PowerShell-redirect levert een kapotte PNG. `adb shell screencap` plus `adb pull` wel.
- `dart format .` faalt door een kapot pad in `build/`.
- `flutter run` verbreekt bij `am force-stop`. Dat is verwacht. De sessietest is daarna met `am start` gedaan.

## 10. Aannames

- Debug-build heeft INTERNET via het debug-manifest. De handmatige API-testen (registreren, inloggen, team) bewijzen dus niet dat het hoofdmanifest al INTERNET had. Die permissie is in stap 2 alsnog in main gezet.
- Testaccount `hr17014445` bestond nog niet. De tweede registratie gaf geen `Username already taken`.
- T-08 `match_repository.dart` was untracked en hoorde bij T-08, niet bij een eerdere gemergede taak.

## 11. Git

Branch: `fix/verificatie-herstel`
Commits (`git log --oneline` van deze branch):
```
08eec76 fix: validatiemelding verdwijnt bij invoer
ac15dcc fix: INTERNET-permissie in het hoofdmanifest
66d8449 fix: compileSdk 37 zodat flutter_secure_storage bouwt
```
Daarna volgt op dezelfde branch de commit `docs: rapport herstel na verificatie` (dit bestand).
Pull request aangemaakt: ja (https://github.com/pmecpmec/CPD/pull/6 voor de drie herstelcommits; dit rapport is een extra commit op dezelfde branch)
Gemerged naar `dev`: ja voor de drie herstelcommits (PR #6). Dit rapportbestand zat daar nog niet in.

PR #4 gemerged: ja (https://github.com/pmecpmec/CPD/pull/4)
PR #5 gemerged: ja (https://github.com/pmecpmec/CPD/pull/5)

## 12. Voor de volgende taak

T-08 ligt buiten de repo in `C:\Users\pmec\Documents\School\CPD\_t08-parkeren\`. Die map terugzetten als T-08 wordt gebouwd. Niet uit git, want die bestanden stonden untracked.

`dev` bevat nu herstel + T-04 (QR) + T-06 (event aanmaken). Analyze en test zijn groen op die stand.

CMake 3.22.1 staat in `C:\Users\pmec\AppData\Local\Android\Sdk\cmake\3.22.1`. Die hoeft niet opnieuw gedownload te worden.

Het rapportcommit moet nog naar `dev`. PR #6 is al gemerged. Na deze commit is een nieuwe PR naar `dev` nodig, of een merge van de branch.
