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
