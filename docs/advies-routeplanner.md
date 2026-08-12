# Advies — routeplanner naar een event (FR-17)

Korte vastlegging van de keuzes uit taak **T-07**, zodat ze in het adviesrapport onderbouwd kunnen worden.
Bron voor de vorm van de gegevens: `docs/api-waargenomen-gedrag.md`, stap 12 en 13.

## Het probleem

Een event heeft in de API geen adres maar een coördinatenpaar (`location.latitude` en `location.longitude`).
De gebruiker moet daar vanuit het eventdetail een route naartoe kunnen starten, op web én op Android.

## Overwogen alternatieven

| Alternatief | Waarom niet |
|---|---|
| Kaart in de app, met `google_maps_flutter` | Staat als Won't have in de scope: een ingebouwde kaart vraagt API-sleutels, een tweede configuratie per platform en meer bouwtijd dan er is |
| Altijd een Google Maps-URL, ook op Android | Werkt, maar dwingt Google Maps af. Met `geo:` kiest het toestel de kaart-app die de gebruiker zelf heeft ingesteld |
| `google.navigation:q=` op Android | Start direct de navigatie, maar is Google-specifiek en niet wat de opdracht vraagt |
| De platformkeuze in het scherm, met `if (kIsWeb)` | Maakt het scherm afhankelijk van het platform en daarmee slechter te testen (NFR-06) |

## De keuze

De URL-opbouw staat in één plek, `lib/features/events/route_starter.dart`, en de externe kaart wordt geopend
met `url_launcher`:

| Platform | URL |
|---|---|
| Android | `geo:52.5168,5.4714?q=52.5168,5.4714(Windesheim%20Almere)` |
| Web en overig | `https://www.google.com/maps/dir/?api=1&destination=52.5168,5.4714` |

- De `q`-parameter bij `geo:` zet een pin op de plek; zonder die parameter centreert de kaart alleen. De naam
  tussen haken komt uit `metadata.locatieNaam`, of anders uit de titel van het event, want een leesbaar label
  is het enige wat de coördinaten begrijpelijk maakt.
- Op web wordt de kaart met `webOnlyWindowName: '_blank'` in een nieuw tabblad geopend, zodat de app blijft staan.
- Desktop valt op de web-URL terug: een browser is er altijd, een `geo:`-handler niet.

## Gevolgen en aandachtspunten

- **Getest zonder toestel.** `bouwKaartUrl` is een pure functie en de platformbepaling en het openen van de URL
  zijn injecteerbaar. `test/unit/route_starter_test.dart` controleert daarmee beide URL's zonder dat er een
  kaart opengaat — nodig, omdat er op de ontwikkelmachine geen Android SDK staat.
- **Geen `canLaunchUrl`.** Die vraagt op Android 11 en hoger een `<queries>`-blok in `AndroidManifest.xml` en
  geeft op web bijna altijd `false`. De app roept daarom rechtstreeks `launchUrl` aan en gebruikt de
  terugkoppeling daarvan.
- **Ontbrekende kaart-app.** Op Android gooit `url_launcher` dan een `PlatformException` met code
  `ACTIVITY_NOT_FOUND` in plaats van `false` terug te geven. Dat wordt afgevangen en levert een melding op,
  geen crash (NFR-03).
- **Onzinnige coördinaten.** In de bestaande gegevens op de server staat een match op `0,0`. De URL blijft
  geldig; de app kan niet weten dat de plek onbedoeld is en gaat er niet op controleren.
