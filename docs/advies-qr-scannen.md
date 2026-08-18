# Advies — QR-uitnodiging scannen (FR-10)

Korte vastlegging van de keuzes uit taak **T-05**.

## Het probleem

De beheerder toont een QR-code met het team-id (T-04). Wie die scant, moet
zichzelf toevoegen met `POST /teams/{id}/addUser`. Cameratoegang werkt op
Android en web anders, en een emulator heeft vaak geen echte camera.

## Overwogen alternatieven

| Alternatief | Waarom niet |
|---|---|
| Eigen parser naast `TeamUitnodiging.leesTeamId` | De vorm ligt al vast in `config.dart`. Een tweede parser kan stil afwijken van wat T-04 toont |
| `permission_handler` alleen, zonder `mobile_scanner` | `mobile_scanner` zat al in de pubspec en dekt preview plus detectie. Een tweede camera-pakket zou dubbel werk zijn |
| Native `MethodChannel` om instellingen te openen | Extra Kotlin in `MainActivity`, terwijl `permission_handler.openAppSettings` dat al doet op Android |
| Na een mislukte scan de scanner sluiten | De taak vraagt dat een verkeerd formaat een melding geeft en de scanner openhoudt |

## De keuze

- **Parser:** alleen `TeamUitnodiging.leesTeamId`. Ongeldig formaat blijft op
  het scanscherm.
- **Al lid:** eerst `haalTeam`, daarna pas `voegGebruikerToe`. De API geeft bij
  een dubbele addUser 200 zonder fout (meting T-03, stap 15). Zonder die check
  is "al lid" niet te onderscheiden van "net toegevoegd".
- **Team niet gevonden:** `NietGevondenException` uit `errors.dart`.
- **Toestemming geweigerd:** uitleg plus knop Instellingen. Op web opent die
  knop niets; de browser houdt cameratoestemming zelf bij. Zie
  `docs/platformverschillen.md`.
- **Tests:** de widgettest zet `cameraGeweigerd: true` zodat `MobileScanner`
  niet start. Een widgettest met een echte camera is op de CI-runner niet
  uitvoerbaar.
