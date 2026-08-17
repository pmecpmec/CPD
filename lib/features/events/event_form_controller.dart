import 'package:flutter/foundation.dart';

import '../../core/errors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/event_repository.dart';

/// Logica achter het formulier voor een nieuw event (FR-11).
///
/// Het formulier houdt zijn eigen invoer bij in tekstvelden; wat hier staat is
/// alles wat niet in een `TextFormField` past of wat getest moet kunnen worden
/// zonder scherm: de gekozen momenten, de controle erop en de aanroep naar de
/// repository.
///
/// De begin- en eindtijd zijn **lokale** momenten. De omzetting naar UTC voor
/// de API gebeurt in `ApiEventRepository`, op één plek — zie de meting in
/// `docs/api-waargenomen-gedrag.md`, stap 12.
class EventFormController extends ChangeNotifier {
  EventFormController({
    required EventRepository eventRepository,
    required this.teamId,
    DateTime? nu,
  }) : _events = eventRepository,
       _nu = nu ?? DateTime.now() {
    _begin = _volgendeHeleUur(_nu);
    _eind = _begin.add(standaardDuur);
  }

  /// Hoe lang een event standaard duurt zolang de gebruiker de eindtijd niet
  /// aanpast.
  static const Duration standaardDuur = Duration(hours: 1);

  final EventRepository _events;

  /// Het team waarvoor het event wordt aangemaakt. Alleen de beheerder van dit
  /// team komt bij het formulier (FR-11).
  final int teamId;

  /// Het moment waarop het formulier is geopend. Injecteerbaar, zodat een test
  /// niet van de klok van de machine afhangt.
  final DateTime _nu;

  late DateTime _begin;
  late DateTime _eind;
  bool _bezig = false;
  String? _foutmelding;

  DateTime get begin => _begin;
  DateTime get eind => _eind;

  /// Er loopt een verzoek naar de server; knoppen horen dan uit te staan.
  bool get bezig => _bezig;

  /// Melding van de server, of van een fout die niet bij één veld hoort.
  String? get foutmelding => _foutmelding;

  /// Grenzen voor de datumkiezer. Een event in het verleden mag: het rooster
  /// toont verleden en toekomst naast elkaar (FR-13), en een correctie achteraf
  /// hoort mogelijk te zijn.
  DateTime get vroegsteDatum => DateTime(_nu.year - 1);
  DateTime get laatsteDatum => DateTime(_nu.year + 5, 12, 31);

  /// Waarom de gekozen periode niet klopt, of `null` wanneer die wel klopt.
  ///
  /// Dit is de enige controle die twee velden tegen elkaar afweegt, en dus de
  /// enige die niet in een veldvalidator past.
  String? get periodeFout =>
      _eind.isAfter(_begin) ? null : 'De eindtijd moet ná de begintijd liggen.';

  void zetBegin(DateTime moment) {
    _begin = moment;
    notifyListeners();
  }

  void zetEind(DateTime moment) {
    _eind = moment;
    notifyListeners();
  }

  /// Maakt het event aan en geeft het terug, of `null` wanneer dat niet lukte.
  /// De reden staat dan in [foutmelding].
  ///
  /// De aanroeper controleert eerst de veldvalidatie van het formulier; deze
  /// methode weigert alleen nog de periode, want die controle staat hier.
  Future<Event?> maakEvent({
    required String titel,
    required String beschrijving,
    required String breedtegraad,
    required String lengtegraad,
    required String locatieNaam,
  }) async {
    if (_bezig) return null;
    if (periodeFout != null) {
      _foutmelding = periodeFout;
      notifyListeners();
      return null;
    }

    _bezig = true;
    _foutmelding = null;
    notifyListeners();

    try {
      final naam = locatieNaam.trim();
      return await _events.maakEvent(
        teamId: teamId,
        titel: titel.trim(),
        beschrijving: beschrijving.trim(),
        start: _begin,
        eind: _eind,
        locatie: _leesLocatie(breedtegraad, lengtegraad),
        locatieNaam: naam.isEmpty ? null : naam,
      );
    } on AppException catch (e) {
      _foutmelding = e.bericht;
      return null;
    } catch (_) {
      _foutmelding = 'Er ging iets onverwachts mis. Probeer het opnieuw.';
      return null;
    } finally {
      _bezig = false;
      notifyListeners();
    }
  }

  /// Coördinaten zijn optioneel: zonder locatie is er alleen geen route te
  /// plannen (FR-17). Zijn ze ingevuld, dan zijn ze door de veldvalidatie al
  /// goedgekeurd.
  GeoLocatie? _leesLocatie(String breedtegraad, String lengtegraad) {
    final noord = leesCoordinaat(breedtegraad);
    final oost = leesCoordinaat(lengtegraad);
    if (noord == null || oost == null) return null;
    return GeoLocatie(latitude: noord, longitude: oost);
  }
}

/// Het eerstvolgende hele uur na [moment]. Een agenda-item begint zelden op
/// 14:37, dus dat is een bruikbaarder startpunt dan "nu".
DateTime _volgendeHeleUur(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day, moment.hour + 1);

/// Leest een coördinaat uit een tekstveld, of geeft `null` bij een leeg of
/// onleesbaar veld.
///
/// De komma wordt als decimaalteken geaccepteerd: een Nederlands toetsenbord
/// biedt die aan en `double.tryParse` kan er niet mee omgaan.
double? leesCoordinaat(String? tekst) {
  final opgeschoond = tekst?.trim().replaceAll(',', '.') ?? '';
  if (opgeschoond.isEmpty) return null;
  return double.tryParse(opgeschoond);
}

/// Valideert de breedtegraad (-90 tot 90). Leeg mag: dan krijgt het event geen
/// locatie.
String? valideerBreedtegraad(String? waarde) =>
    _valideerCoordinaat(waarde, grens: 90, veld: 'breedtegraad');

/// Valideert de lengtegraad (-180 tot 180).
String? valideerLengtegraad(String? waarde) =>
    _valideerCoordinaat(waarde, grens: 180, veld: 'lengtegraad');

String? _valideerCoordinaat(
  String? waarde, {
  required double grens,
  required String veld,
}) {
  if ((waarde?.trim() ?? '').isEmpty) return null;

  final getal = leesCoordinaat(waarde);
  if (getal == null) return 'Vul een getal in, bijvoorbeeld 52.5168.';
  if (getal < -grens || getal > grens) {
    return 'Een $veld ligt tussen ${-grens.toInt()} en ${grens.toInt()}.';
  }
  return null;
}

/// Controleert dat de coördinaten samen worden ingevuld. Eén helft is geen
/// locatie, en stil weglaten is erger dan een melding: de gebruiker denkt dan
/// dat er een plek bij het event staat.
String? valideerCoordinatenpaar(String? breedtegraad, String? lengtegraad) {
  final noord = (breedtegraad?.trim() ?? '').isNotEmpty;
  final oost = (lengtegraad?.trim() ?? '').isNotEmpty;
  return noord == oost
      ? null
      : 'Vul beide coördinaten in, of laat ze beide leeg.';
}

/// Valideert de titel: het enige veld dat de API verplicht stelt.
String? valideerTitel(String? waarde) =>
    (waarde?.trim().isEmpty ?? true) ? 'Vul een titel in.' : null;
