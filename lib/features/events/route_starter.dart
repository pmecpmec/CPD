/// Het starten van een route naar de locatie van een event (FR-17).
///
/// De API bewaart een locatie als coördinatenpaar en niet als adres, dus er
/// valt niets anders door te geven dan breedte- en lengtegraad. Elk platform
/// doet dat op zijn eigen manier, en dat verschil hoort op één plek te staan —
/// het scherm hoeft er niets van te weten.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/models.dart';

/// De vormen waarin de app een kaart-URL opbouwt.
///
/// - [android] gebruikt het `geo:`-schema. Daarmee kiest het toestel de
///   kaart-app die de gebruiker zelf heeft ingesteld, in plaats van dat de app
///   Google Maps voorschrijft.
/// - [web] krijgt een Google Maps-URL over https. Er is in de browser geen
///   kaart-app om naartoe te schakelen, en `geo:` werkt daar niet.
///
/// Andere platformen dan Android — desktop tijdens het ontwikkelen — vallen
/// terug op [web]: een browser is er altijd.
enum KaartPlatform { android, web }

/// Bepaalt de vorm die bij het huidige platform hoort.
///
/// Staat los van [bouwKaartUrl] zodat een test elke vorm kan opbouwen zonder
/// op een echt toestel te draaien (NFR-06).
KaartPlatform huidigKaartPlatform() =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
    ? KaartPlatform.android
    : KaartPlatform.web;

/// Opent een URL. In productie is dit `url_launcher`; in een test een functie
/// die de URL alleen onthoudt.
typedef UrlOpener = Future<bool> Function(Uri url);

/// De vorm waarin een scherm een route start, zonder de platformkeuze te kennen.
typedef RouteStarter =
    Future<bool> Function(GeoLocatie locatie, {String? label});

/// Melding wanneer er geen kaart-app of browser op de URL reageert. Staat hier
/// en niet in het scherm, omdat dit de laag is die weet wat er kan mislukken.
const String geenKaartAppMelding =
    'Er is geen kaart-app gevonden om de route te openen.';

/// Bouwt de kaart-URL voor [locatie] in de vorm die bij [platform] hoort.
///
/// [label] is een leesbare plaatsnaam, bijvoorbeeld uit `metadata.locatieNaam`.
/// Op Android komt die als naam bij de pin te staan; de Google Maps-URL voor
/// web heeft hem niet nodig, omdat die rechtstreeks een route naar de
/// coördinaten opent.
Uri bouwKaartUrl(
  GeoLocatie locatie, {
  required KaartPlatform platform,
  String? label,
}) {
  final coordinaten = '${locatie.latitude},${locatie.longitude}';
  return switch (platform) {
    // `geo:<coördinaten>` centreert de kaart; de `q`-parameter zet er ook een
    // pin op, zodat de gebruiker meteen op navigeren kan drukken.
    KaartPlatform.android => Uri.parse(
      'geo:$coordinaten?q=$coordinaten${_labelDeel(label)}',
    ),
    KaartPlatform.web => Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$coordinaten',
    ),
  };
}

/// Start een route naar [locatie] en meldt of dat gelukt is.
///
/// [bepaalPlatform] en [openUrl] zijn injecteerbaar, zodat een test de
/// opgebouwde URL kan controleren zonder dat er echt iets opengaat (NFR-06).
///
/// Staat er op Android geen kaart-app op het toestel, dan gooit url_launcher een
/// `PlatformException` met code `ACTIVITY_NOT_FOUND` in plaats van `false` terug
/// te geven. Dat wordt hier afgevangen: een ontbrekende kaart-app is een melding
/// aan de gebruiker, geen crash (NFR-03).
Future<bool> startRoute(
  GeoLocatie locatie, {
  String? label,
  KaartPlatform Function() bepaalPlatform = huidigKaartPlatform,
  UrlOpener openUrl = _openInKaartApp,
}) async {
  final url = bouwKaartUrl(locatie, platform: bepaalPlatform(), label: label);
  try {
    return await openUrl(url);
  } on PlatformException {
    return false;
  }
}

/// Een lege naam levert geen label op; anders komt hij tussen ronde haken
/// achter de coördinaten, zoals het `geo:`-schema voorschrijft.
String _labelDeel(String? label) {
  final naam = label?.trim() ?? '';
  return naam.isEmpty ? '' : '(${Uri.encodeComponent(naam)})';
}

/// `webOnlyWindowName: '_blank'` laat de kaart op web in een nieuw tabblad
/// opengaan, zodat de app zelf blijft staan. Op Android negeert url_launcher
/// die parameter en start het de kaart-app via het `geo:`-schema.
Future<bool> _openInKaartApp(Uri url) => launchUrl(
  url,
  mode: LaunchMode.externalApplication,
  webOnlyWindowName: '_blank',
);
