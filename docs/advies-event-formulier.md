# Advies — een event aanmaken met een locatie (FR-11)

Korte vastlegging van de keuzes uit taak **T-06**. Bron voor de vorm van de gegevens:
`docs/api-waargenomen-gedrag.md`, stap 12.

## Het probleem

De API bewaart de plek van een event als **coördinatenpaar** (`location.latitude`, `location.longitude`) en
niet als adres. Een gebruiker denkt in "sporthal in Almere", niet in `52.5168, 5.4714`. Tussen die twee zit
normaal een geocodeerdienst, en die is er niet.

## Overwogen alternatieven

| Alternatief | Waarom niet |
|---|---|
| Een adresveld en dat omzetten met een geocodeerdienst (Nominatim, Google Geocoding) | Een externe dienst erbij, met sleutel, gebruiksvoorwaarden en foutafhandeling. De opdracht vraagt het niet en de tijd is er niet |
| Een kaart waarop de gebruiker een punt prikt | Ingebouwde kaartweergave staat als Won't have in de scope (`SCOPE-en-REQUIREMENTS.md`) |
| Alleen coördinaten, zonder plaatsnaam | Dan tonen het rooster en het eventdetail alleen getallen. Onbruikbaar voor wie moet weten waar hij heen gaat |
| De locatie verplicht stellen | De API doet dat niet, en een teamoverleg zonder plek is een legitiem event. Zonder locatie is alleen de routeknop uitgeschakeld (FR-17) |

## De keuze

Twee getalvelden voor de coördinaten, plus een vrij veld "Plaatsnaam" dat als `metadata.locatieNaam` mee gaat.
`metadata` is in deze API vrij invulbaar en komt ongewijzigd terug, dus het is een veilige plek voor gegevens
die het schema niet kent. Het eventdetail toont de plaatsnaam boven de coördinaten, en de routeplanner gebruikt
hem als label bij de pin op de kaart.

Verder:

- **Alles wordt vóór verzending gecontroleerd** (FR-11): titel niet leeg, breedtegraad tussen -90 en 90,
  lengtegraad tussen -180 en 180, en de eindtijd ná de begintijd. Er gaat dus geen verzoek uit dat de server
  toch zou weigeren. De validatiefuncties staan in `event_form_controller.dart` en niet in de widget, zodat de
  widgettest ze via het scherm kan aanspreken zonder netwerk (NFR-06).
- **De komma wordt als decimaalteken geaccepteerd.** Een Nederlands toetsenbord biedt die aan en
  `double.tryParse` struikelt erover. `leesCoordinaat` trekt komma en punt gelijk.
- **Coördinaten horen bij elkaar.** Eén helft ingevuld levert een melding op in plaats van een stil weggelaten
  locatie: anders denkt de gebruiker dat er een plek bij het event staat.
- **De begintijd staat op het eerstvolgende hele uur** en de eindtijd een uur later. Een agenda-item begint
  zelden op 14:37, en zo is de meest voorkomende invoer al goed.
- **"Nu" is injecteerbaar** in de controller. Een test die van `DateTime.now()` afhangt, faalt een keer per jaar
  om middernacht; deze niet.
- **Tijden gaan als UTC de deur uit** en worden lokaal getoond. Die omzetting staat op één plek, in
  `ApiEventRepository`, en niet in het formulier.

## Gevolgen en aandachtspunten

- **De gebruiker moet coördinaten kunnen opzoeken.** Dat is de prijs van deze keuze: in de praktijk kopieert
  hij die uit een kaart-app. Het invoerveld geeft `52.5168` als voorbeeld. Een geocodeerdienst hoort op de
  wensenlijst, en die keuze is bewust uitgesteld en niet vergeten.
- **De datum- en tijdkiezer van Material** wordt gebruikt zoals hij is, dus op web krijgt de gebruiker de
  Material-variant met invoerveld en op Android dezelfde dialoog met klok. Dat is precies de "eigen stijl over
  beide platformen"-keuze die het adviesrapport als voorbeeld noemt.
- **Datum- en tijdopmaak staat nu in `lib/shared/datum_tekst.dart`.** Die stond eerst privé in het
  eventdetailscherm; het formulier is de tweede plek en het rooster (T-08, T-09) wordt de derde. Eén kopie in
  plaats van drie.
- **Nog te controleren op een echt toestel:** of de datum- en tijdkiezer op een klein Android-scherm bruikbaar
  blijft, en of het numerieke toetsenbord daar zowel een minteken als een komma aanbiedt. Op de
  ontwikkelmachine staat geen Android SDK, dus dat is niet geverifieerd.
