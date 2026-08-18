# Rapport T-XX — <titel van de taak>

Vul dit sjabloon volledig in. Kopieer het naar `docs/rapport-T-XX.md` en vervang XX door het taaknummer.
Laat geen veld leeg. Weet je iets niet, schrijf dan letterlijk `NIET GEDAAN` of `WEET IK NIET`.

Verzin niets. Als een stap niet is uitgevoerd, schrijf dan dat hij niet is uitgevoerd. Een eerlijk rapport met
drie mislukte stappen is bruikbaar. Een rapport dat succes meldt terwijl er iets niet is gedaan, is schadelijk,
want er wordt documentatie op gebaseerd die daarna niet klopt.

---

## 1. Wat er gevraagd was

Taaknummer:
Requirements:
Branch:

## 2. Bestanden

Nieuw aangemaakt:
- `pad/naar/bestand.dart` — wat het doet

Gewijzigd:
- `pad/naar/bestand.dart` — wat er is veranderd en waarom

Verwijderd:
-

## 3. Commando's die ik heb gedraaid

Plak de uitvoer erbij, ook als die lang is. Niet samenvatten.

```
$ flutter analyze
<plak hier de volledige uitvoer>
```

```
$ flutter test
<plak hier de volledige uitvoer, inclusief het aantal geslaagde en gefaalde tests>
```

```
$ dart format .
<plak hier de uitvoer>
```

## 4. Tests

| Testbestand | Aantal tests | Geslaagd | Gefaald |
|---|---|---|---|
| | | | |

Welk requirement dekt elke test? Noem per test het FR- of NFR-nummer.

## 5. Handmatig getest

| Platform | Getest? | Wat ik heb gedaan | Wat er gebeurde |
|---|---|---|---|
| Web (`flutter run -d chrome`) | ja / nee | | |
| Android (emulator of toestel) | ja / nee | | |

Heb je het niet handmatig gedraaid, schrijf dan `NIET GEDAAN` en waarom.

## 6. Acceptatiecriteria uit de taak

Neem elk acceptatiecriterium uit de taakbeschrijving letterlijk over en zet erachter of het gehaald is.

| Criterium (letterlijk uit de taak) | Gehaald? | Hoe vastgesteld |
|---|---|---|
| | ja / nee / deels | |

## 7. Wat ik NIET heb gedaan

Alles uit de taak dat je hebt overgeslagen, met de reden. Ook kleine dingen.

-

## 8. Keuzes die ik heb gemaakt

Elke technische keuze die niet letterlijk in de taak stond. Per keuze: wat je koos, welk alternatief je had, en
waarom. Dit is materiaal voor het adviesrapport, dus wees concreet.

| Keuze | Alternatief | Reden |
|---|---|---|
| | | |

## 9. Waar ik tegenaan liep

Fouten, verrassingen, dingen die anders werkten dan verwacht. Ook als je ze hebt opgelost.

-

## 10. Aannames

Alles waarvan je niet zeker wist of het klopte, maar waar je toch vanuit bent gegaan.

-

## 11. Git

Branch:
Commits (`git log --oneline` van deze branch):
```
```
Pull request aangemaakt: ja / nee
Gemerged naar `dev`: ja / nee

## 12. Voor de volgende taak

Wat moet iemand weten die hierna verdergaat?

-
