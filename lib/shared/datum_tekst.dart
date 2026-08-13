/// Datum en tijd in leesbare Nederlandse vorm.
///
/// De app heeft geen `intl`-pakket: dat zou voor twee schermen een extra
/// afhankelijkheid en een lokalisatie-opzet betekenen, terwijl er maar één taal
/// is. De maandnamen staan daarom hieronder.
///
/// Alle functies gaan uit van een **lokale** [DateTime]. De API levert UTC en
/// de modellen rekenen dat bij het inlezen al om, dus hier wordt niets meer
/// omgezet — zie `Event.start`.
library;

/// `13 augustus 2026`
String datumTekst(DateTime moment) =>
    '${moment.day} ${_maanden[moment.month - 1]} ${moment.year}';

/// `15:01`
String tijdTekst(DateTime moment) =>
    '${moment.hour.toString().padLeft(2, '0')}:'
    '${moment.minute.toString().padLeft(2, '0')}';

/// Begin- en eindtijd in één regel. Valt het geheel binnen één dag, dan staat
/// de datum er één keer: `13 augustus 2026, 15:01 – 17:01`.
String periodeTekst(DateTime start, DateTime eind) {
  final zelfdeDag =
      start.year == eind.year &&
      start.month == eind.month &&
      start.day == eind.day;
  final begin = '${datumTekst(start)}, ${tijdTekst(start)}';
  return zelfdeDag
      ? '$begin – ${tijdTekst(eind)}'
      : '$begin – ${datumTekst(eind)}, ${tijdTekst(eind)}';
}

const List<String> _maanden = [
  'januari',
  'februari',
  'maart',
  'april',
  'mei',
  'juni',
  'juli',
  'augustus',
  'september',
  'oktober',
  'november',
  'december',
];
