# Advies — bekende API-foutmeldingen in het Nederlands (NFR-03)

Korte vastlegging bij de acceptatiebevinding dat de server Engelse teksten teruggeeft.

## Het probleem

De API stuurt fouten als `"Username already taken"` en `"Invalid username or password"`.
Die teksten kwamen ongewijzigd in beeld. De gebruiker ziet overal verder Nederlands.

## Overwogen alternatieven

| Alternatief | Waarom niet |
|---|---|
| Alle serverteksten zelf verzinnen en de API-melding negeren | Dan verdwijnt ook een onbekende, nuttige melding. Nieuwe fouten van de server worden onzichtbaar |
| Een vertaalpakket of meertaligheid | Buiten scope (Won't have). Vier teksten rechtvaardigen geen extra afhankelijkheid |
| Vertalen in elk scherm | Foutafhandeling hoort in `errors.dart` / `ApiClient`, niet in widgets |

## De keuze

Eén functie `vertaalServerFout` in `lib/core/errors.dart`, aangeroepen vanuit `ApiClient` bij het lezen van het foutveld.
Alleen deze vier teksten worden vertaald. Een onbekende tekst blijft staan zoals de server hem stuurde.

404 gebruikt nu ook de servermelding, omdat `GET /teams/{id}` bij een ontbrekend team `"Team not found"` teruggeeft.
Zonder die stap zou de vertaling van die tekst de gebruiker niet bereiken.
