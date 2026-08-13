import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/features/events/route_starter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests voor de routeplanner (FR-17).
///
/// De platformkeuze en het openen van de URL zijn injecteerbaar, dus deze tests
/// controleren de opgebouwde URL voor beide platformen zonder dat er een
/// kaart-app of browser aan te pas komt (NFR-06). Dat maakt de Android-URL ook
/// hier controleerbaar, op een machine zonder Android SDK.
void main() {
  // Windesheim Almere, dezelfde coördinaten als in het verkenningsscript.
  const almere = GeoLocatie(latitude: 52.5168, longitude: 5.4714);

  group('bouwKaartUrl', () {
    test('gebruikt op Android het geo-schema met een pin op de locatie', () {
      final url = bouwKaartUrl(almere, platform: KaartPlatform.android);

      expect(url.scheme, 'geo');
      expect(url.toString(), 'geo:52.5168,5.4714?q=52.5168,5.4714');
    });

    test('zet een leesbare plaatsnaam als label bij de pin', () {
      final url = bouwKaartUrl(
        almere,
        platform: KaartPlatform.android,
        label: 'Windesheim Almere',
      );

      expect(
        url.toString(),
        'geo:52.5168,5.4714?q=52.5168,5.4714(Windesheim%20Almere)',
      );
    });

    test('laat het label weg wanneer er geen plaatsnaam bekend is', () {
      final url = bouwKaartUrl(
        almere,
        platform: KaartPlatform.android,
        label: '   ',
      );

      expect(url.toString(), 'geo:52.5168,5.4714?q=52.5168,5.4714');
    });

    test('opent op web een Google Maps-route over https', () {
      final url = bouwKaartUrl(almere, platform: KaartPlatform.web);

      expect(url.scheme, 'https');
      expect(url.host, 'www.google.com');
      expect(
        url.toString(),
        'https://www.google.com/maps/dir/?api=1&destination=52.5168,5.4714',
      );
    });

    test('houdt negatieve coördinaten heel op beide platformen', () {
      const sanFrancisco = GeoLocatie(latitude: 37.7749, longitude: -122.4194);

      expect(
        bouwKaartUrl(sanFrancisco, platform: KaartPlatform.android).toString(),
        'geo:37.7749,-122.4194?q=37.7749,-122.4194',
      );
      expect(
        bouwKaartUrl(sanFrancisco, platform: KaartPlatform.web).toString(),
        'https://www.google.com/maps/dir/?api=1&destination=37.7749,-122.4194',
      );
    });

    test('loopt niet stuk op de nulmeridiaan', () {
      // In de bestaande gegevens op de server staat een match met
      // {"latitude": 0, "longitude": 0}: geldig, maar inhoudelijk onzin.
      const nul = GeoLocatie(latitude: 0, longitude: 0);

      expect(
        bouwKaartUrl(nul, platform: KaartPlatform.android).toString(),
        'geo:0.0,0.0?q=0.0,0.0',
      );
    });
  });

  group('huidigKaartPlatform', () {
    test('kiest het geo-schema op een Android-toestel', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      expect(huidigKaartPlatform(), KaartPlatform.android);
    });

    test('valt op andere platformen terug op de web-URL', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      expect(huidigKaartPlatform(), KaartPlatform.web);
    });
  });

  group('startRoute', () {
    test('opent de URL die bij het gekozen platform hoort', () async {
      final geopend = <Uri>[];

      final gelukt = await startRoute(
        almere,
        label: 'Windesheim Almere',
        bepaalPlatform: () => KaartPlatform.android,
        openUrl: (url) async {
          geopend.add(url);
          return true;
        },
      );

      expect(gelukt, isTrue);
      expect(
        geopend.single.toString(),
        'geo:52.5168,5.4714?q=52.5168,5.4714(Windesheim%20Almere)',
      );
    });

    test('meldt het wanneer er niets op de URL reageert', () async {
      final gelukt = await startRoute(
        almere,
        bepaalPlatform: () => KaartPlatform.web,
        openUrl: (_) async => false,
      );

      expect(gelukt, isFalse);
    });

    test('valt niet om als er op Android geen kaart-app staat', () async {
      // url_launcher gooit dan een PlatformException in plaats van false terug
      // te geven; de gebruiker hoort een melding te zien, geen crash (NFR-03).
      final gelukt = await startRoute(
        almere,
        bepaalPlatform: () => KaartPlatform.android,
        openUrl: (_) async => throw PlatformException(
          code: 'ACTIVITY_NOT_FOUND',
          message: 'No Activity found to handle intent',
        ),
      );

      expect(gelukt, isFalse);
    });
  });
}
