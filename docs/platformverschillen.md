# Platformverschillen

Verschillen tussen web en Android die in de app zichtbaar zijn. Geen
commentaar in de code; wat hier staat is de bron.

## Camera voor QR-scannen (FR-10)

De scanner gebruikt hetzelfde scherm op beide platformen. Het verschil zit in
toestemming en in wanneer de camera überhaupt mag.

| | Android | Web |
|---|---|---|
| Toestemming | Het besturingssysteem vraagt om de camera. Die staat in het hoofdmanifest als `CAMERA`. Bij weigering toont de app uitleg en een knop naar de app-instellingen | De browser vraagt om de camera. Er is geen app-instellingenscherm; de knop Instellingen doet op web niets |
| Wanneer de camera mag | Altijd, na toestemming | Alleen op **HTTPS** of op **localhost**. Op een gewoon HTTP-adres weigert de browser `getUserMedia` |
| Emulator | De Android-emulator heeft geen echte camera. Afhankelijk van de AVD-instelling is er een virtuele scène of een gekoppelde webcam, of helemaal geen beeld | Niet van toepassing |

Op web is de bedoelde ontwikkelroute dus `flutter run -d chrome` (dat is
localhost) of een deploy op HTTPS. Een IP-adres over HTTP is geen geldige
test van FR-10.

## Gezien op 17 augustus 2026 (T-08/T-09)

Web: Chrome, poort 9130, eigen Chrome-profiel.
Android: emulator `cpd_test`, id emulator-5554.
App: worktree van `feature/T-08-T-09-roosters` op commit `e76ee38`.

1. Android is merkbaar trager bij het opstarten. Bij `flutter run` sloeg de emulator 201 frames over bij de eerste tekening. Na opnieuw openen van de app verscheen eerst het Flutter-splashscherm (blauw logo op wit) en daarna het inlogscherm. Op web was in deze ronde geen splash te zien. Het inlogscherm stond er meteen.

2. Het thema volgt het systeem. Chrome toonde de app donker. De emulator toonde dezelfde schermen licht. Beide kanten gebruiken dezelfde schermen.

3. Navigatie hangt van de breedte af. Op web bij 1037 pixels stond een NavigationRail links (Teams en Agenda). Op web bij 390 pixels stond een NavigationBar onderaan. Op de emulator (1080x2400) stond dezelfde balk onderaan.

4. Sessie bewaren. Bij `flutter run` op de emulator kwam ik niet op inloggen uit, maar op Mijn teams met team Herstelteam. Dat was een sessie van een eerdere testronde. Op web startte een nieuw Chrome-profiel op het inlogscherm.

5. Camera voor QR-scan. Web mag de camera alleen gebruiken via HTTPS of localhost. Android vraagt om toestemming. Dit is niet in deze ronde uitgeprobeerd. Het verschil komt uit de eerdere documentatie van de QR-uitnodiging.

## Niet vergeleken

- Datum- en tijdkiezer: op web zag ik de knop Wijzigen, maar ik heb de kiezer niet geopend. Op Android heb ik het eventformulier niet geopend.
- Routeknop: op web zichtbaar op het eventdetail. Niet ingedrukt. Op Android niet geopend.
