# Platformverschillen

Gezien op 17 augustus 2026.
Web: Chrome, poort 9130, eigen Chrome-profiel.
Android: emulator `cpd_test`, id emulator-5554.
App: worktree van `feature/T-08-T-09-roosters` op commit `e76ee38`.

## Wat ik zelf heb gezien

1. Android is merkbaar trager bij het opstarten. Bij `flutter run` sloeg de emulator 201 frames over bij de eerste tekening. Na opnieuw openen van de app verscheen eerst het Flutter-splashscherm (blauw logo op wit) en daarna het inlogscherm. Op web was in deze ronde geen splash te zien. Het inlogscherm stond er meteen.

2. Het thema volgt het systeem. Chrome toonde de app donker. De emulator toonde dezelfde schermen licht. Beide kanten gebruiken dezelfde schermen.

3. Navigatie hangt van de breedte af. Op web bij 1037 pixels stond een NavigationRail links (Teams en Agenda). Op web bij 390 pixels stond een NavigationBar onderaan. Op de emulator (1080x2400) stond dezelfde balk onderaan.

4. Sessie bewaren. Bij `flutter run` op de emulator kwam ik niet op inloggen uit, maar op Mijn teams met team Herstelteam. Dat was een sessie van een eerdere testronde. Op web startte een nieuw Chrome-profiel op het inlogscherm.

## Uit de specificatie, camera niet in deze ronde getest

5. Camera voor QR-scan. Web mag de camera alleen gebruiken via HTTPS of localhost. Android vraagt om toestemming. Dit is niet in deze ronde uitgeprobeerd. Het verschil komt uit de eerdere documentatie van de QR-uitnodiging.

## Niet vergeleken

- Datum- en tijdkiezer: op web zag ik de knop Wijzigen, maar ik heb de kiezer niet geopend. Op Android heb ik het eventformulier niet geopend.
- Routeknop: op web zichtbaar op het eventdetail. Niet ingedrukt. Op Android niet geopend.
