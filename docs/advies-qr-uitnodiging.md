# Advies — uitnodigen met een QR-code (FR-09)

Korte vastlegging van de keuzes uit taak **T-04**, zodat ze in het adviesrapport onderbouwd kunnen worden.
Bron voor wat de API wel en niet kan: `docs/api-waargenomen-gedrag.md`, stap 10 en 15.

## Het probleem

De opdracht eist dat een lid alleen via een uitnodiging in een team komt: aanmelden mag niet. De API heeft
daar géén endpoint voor. Wat er is, is `POST /teams/{id}/addUser` met een `userId` in de body — en dat is de
omgekeerde richting: de beheerder moet het id van de ander al kennen, terwijl hij dat nergens kan opzoeken.
Er is geen endpoint om een gebruiker op naam te vinden.

## Overwogen alternatieven

| Alternatief | Waarom niet |
|---|---|
| Beheerder vult het gebruikers-id in en roept `addUser` aan | Werkt technisch, maar een gebruiker kent zijn eigen id niet: dat staat alleen in het inlogantwoord. En de opdracht vraagt expliciet om een QR-code |
| Een uitnodigingstoken van de server in de code | Zou het veiligst zijn, maar de API kent geen uitnodigingen en die kan niet worden uitgebreid: alleen de front-end is van ons |
| Een deelbare link (`https://.../join/42`) in plaats van een code | Vraagt deep links per platform en een gehoste webversie op een vast adres. De camera-eis uit de vakbeschrijving wordt er niet mee gedekt |
| Het hele team als JSON in de QR-code | Maakt de code veel groter en dus moeilijker te scannen, terwijl de scanner het team daarna toch bij de server ophaalt |

## De keuze

De QR-code bevat alleen het team-id, in één vaste vorm die in `TeamUitnodiging` (`lib/core/config.dart`)
vastligt:

```
teamplanner:team:42
```

De beheerder toont de code; wie hem scant leest het team-id eruit en voegt **zichzelf** toe met zijn eigen id
uit `AuthRepository.huidigeGebruikerId()`. Zo is `addUser` toch bruikbaar zonder dat iemand het id van een
ander hoeft te kennen.

- **Eén plek voor het formaat.** `bouwCode` schrijft de code, `leesTeamId` leest hem terug. Tonen (FR-09) en
  scannen (FR-10) delen niets anders; wijkt de een af, dan werkt het scannen stil niet meer terwijl geen
  enkel scherm stukloopt. Daarom legt `test/unit/team_uitnodiging_test.dart` de vorm vast, inclusief de
  heen-en-terugweg.
- **Een voorvoegsel, geen los getal.** Zonder `teamplanner:team:` is een willekeurige QR-code op een poster
  niet te onderscheiden van een uitnodiging.
- **Een dialoog, geen apart scherm.** De code is één ding om te laten zien en heeft geen eigen navigatiestap
  nodig; een dialoog werkt op web en Android hetzelfde.
- **240 bij 240 logische pixels, met witte rand.** De opdracht vraagt een code die van een laptopscherm te
  scannen is. De rand is expliciet wit en volgt níét het thema: op een donkere achtergrond zonder stille zone
  herkent een scanner de code niet. Foutcorrectie staat op niveau M in plaats van de standaard L, zodat een
  reflectie op het scherm de code niet onleesbaar maakt.
- **De code staat ook als tekst onder de afbeelding.** Dat is er in eerste instantie voor de gebruiker zonder
  camera bij de hand, en het maakt de widgettest mogelijk: `QrImageView` houdt zijn data privé.

## Gevolgen en aandachtspunten

- **De code verloopt niet en is niet persoonlijk.** Wie hem ooit heeft gezien, kan zich blijven toevoegen. Dat
  is een gevolg van een API zonder uitnodigingen, geen ontwerpkeuze. Het risico is beperkt: het team-id is een
  oplopend getal en dus toch al te raden, en de beheerder kan een lid verwijderen (FR-08). Een uitnodiging met
  geldigheidsduur hoort op de wensenlijst voor de back-end.
- **Alleen de beheerder ziet de knop.** Dat is een keuze van de app: de API laat `addUser` ook door een gewoon
  lid uitvoeren zolang het niet om verwijderen gaat.
- **Nog te controleren op een echt toestel:** of een telefooncamera de code van een laptopscherm leest. Op de
  ontwikkelmachine staat geen Android SDK (`flutter doctor` meldt "Unable to locate Android SDK"), dus dat is
  niet geverifieerd. De widgettest bewijst alleen de afmeting en de witte rand, niet de leesbaarheid.
