import '../../data/models/models.dart';

/// De logica achter het rooster: één soort regel voor events en matches, de
/// status die bij een match hoort, en het sorteren en scheiden van verleden en
/// toekomst.
///
/// Dit staat los van de widgets omdat het de enige echte logica in het rooster
/// is, en omdat het teamrooster (FR-13) en het persoonlijk rooster (FR-14) het
/// delen. Er komt hier geen `DateTime.now()` in voor: "nu" gaat als parameter
/// mee, zodat een test met een vast moment kan werken.

/// Waar een roosterregel over gaat. Een match is in deze API een event met een
/// lijst uitnodigingen erbij, maar voor de gebruiker is het iets anders: er kan
/// nog op een tegenstander gewacht worden.
enum RoosterSoort { event, match }

/// Eén regel in een rooster.
class RoosterItem {
  const RoosterItem({
    required this.soort,
    required this.id,
    required this.titel,
    required this.start,
    required this.eind,
    required this.teamNamen,
    this.teamIds = const [],
    this.statusLabel,
    this.event,
  });

  /// Bouwt een regel uit een event van één team.
  ///
  /// De teamnaam komt uit het `team`-object dat de API bij elk event meestuurt;
  /// valt dat weg, dan blijft de regel zonder teamnaam over. Het team-id komt
  /// uit [Event.teamId], dat de API altijd meestuurt.
  factory RoosterItem.vanEvent(Event event) => RoosterItem(
    soort: RoosterSoort.event,
    id: event.id,
    titel: event.title,
    start: event.start,
    eind: event.end,
    teamNamen: [if (event.team?.name != null) event.team!.name],
    teamIds: [event.teamId],
    event: event,
  );

  /// Bouwt een regel uit een match, gezien vanuit [eigenTeamIds], de teams van
  /// de gebruiker die bij deze match betrokken zijn.
  ///
  /// Welke status erbij komt te staan hangt af van de kant waar je staat: een
  /// uitgenodigd team ziet zijn eigen antwoord, de organisator ziet of alle
  /// uitgenodigde teams al hebben geaccepteerd (FR-13).
  factory RoosterItem.vanMatch(
    Match match, {
    Set<int> eigenTeamIds = const {},
  }) {
    final betrokkenNamen = <String>[];
    final betrokkenIds = <int>[];

    void voegTeamToe(int? teamId, String? naam) {
      if (teamId == null || betrokkenIds.contains(teamId)) return;
      betrokkenIds.add(teamId);
      if (naam != null && naam.isNotEmpty) betrokkenNamen.add(naam);
    }

    voegTeamToe(match.teamId, match.team?.name);
    for (final invite in match.invites) {
      voegTeamToe(invite.teamId, invite.team?.name);
    }

    return RoosterItem(
      soort: RoosterSoort.match,
      id: match.id,
      titel: match.title,
      start: match.start,
      eind: match.end,
      teamNamen: betrokkenNamen,
      teamIds: betrokkenIds,
      statusLabel: matchStatusLabel(match, eigenTeamIds),
    );
  }

  final RoosterSoort soort;

  /// Id van het onderliggende event of de onderliggende match. Uniek binnen
  /// [soort], niet daarbuiten: het persoonlijk rooster ontdubbelt daarom op de
  /// combinatie van beide (FR-14).
  final int id;

  final String titel;

  /// Begin- en eindtijd in de tijdzone van het apparaat. De API levert UTC en
  /// de modellen rekenen dat bij het inlezen om.
  final DateTime start;
  final DateTime eind;

  /// De teams waar deze regel bij hoort. Bij een event één naam, bij een match
  /// de organisator en de uitgenodigde teams. Kan leeg zijn wanneer de API het
  /// team niet meestuurde.
  final List<String> teamNamen;

  /// De ids die bij [teamNamen] horen, in dezelfde volgorde. Nodig om te
  /// filteren: twee teams kunnen dezelfde naam hebben (FR-14).
  final List<int> teamIds;

  /// Wat er over de acceptatie te melden is, of `null` bij een event.
  final String? statusLabel;

  /// Het onderliggende event, zodat het rooster het detailscherm kan openen
  /// (FR-12). Bij een match `null`: daar is geen detailscherm voor.
  final Event? event;

  /// Sleutel om op te ontdubbelen (FR-14): dezelfde match via twee teams levert
  /// dezelfde sleutel op.
  String get sleutel => '${soort.name}:$id';

  /// Voegt teamnamen en team-ids toe zonder duplicaten. Gebruikt bij het
  /// ontdubbelen van een match die via twee teams in de lijst staat (FR-14).
  ///
  /// [extraIds] en [extra] horen per index bij elkaar. Een id dat er al in
  /// zit wordt overgeslagen, net als een lege of dubbele naam.
  RoosterItem metExtraTeamNamen(
    Iterable<String> extra, {
    Iterable<int> extraIds = const [],
  }) {
    final namen = [...teamNamen];
    final ids = [...teamIds];
    final extraNaamLijst = extra.toList();
    final extraIdLijst = extraIds.toList();
    final lengte = extraIdLijst.length > extraNaamLijst.length
        ? extraIdLijst.length
        : extraNaamLijst.length;

    for (var i = 0; i < lengte; i++) {
      final extraId = i < extraIdLijst.length ? extraIdLijst[i] : null;
      final extraNaam = i < extraNaamLijst.length ? extraNaamLijst[i] : null;
      if (extraId != null) {
        if (ids.contains(extraId)) continue;
        ids.add(extraId);
      }
      if (extraNaam != null &&
          extraNaam.isNotEmpty &&
          !namen.contains(extraNaam)) {
        namen.add(extraNaam);
      }
    }

    return RoosterItem(
      soort: soort,
      id: id,
      titel: titel,
      start: start,
      eind: eind,
      teamNamen: namen,
      teamIds: ids,
      statusLabel: statusLabel,
      event: event,
    );
  }
}

/// De status die bij [match] in het rooster hoort, gezien vanuit
/// [eigenTeamIds].
///
/// Er is geen statusveld op de match zelf; de status staat per uitnodiging.
/// `pending`, `accepted` en `declined` worden naar de Nederlandse labels van
/// [InviteStatus] vertaald. Wie is uitgenodigd, ziet zijn eigen antwoord. De
/// organisator heeft geen uitnodiging en ziet daarom of de anderen al hebben
/// geantwoord.
String matchStatusLabel(Match match, Set<int> eigenTeamIds) {
  for (final invite in match.invites) {
    if (invite.teamId != null && eigenTeamIds.contains(invite.teamId)) {
      return invite.status.label;
    }
  }

  if (match.alleGeaccepteerd) return InviteStatus.accepted.label;
  if (match.invites.any((invite) => invite.status == InviteStatus.pending)) {
    return InviteStatus.pending.label;
  }
  if (match.invites.any((invite) => invite.status == InviteStatus.declined)) {
    return InviteStatus.declined.label;
  }
  if (match.invites.any((invite) => invite.status == InviteStatus.canceled)) {
    return InviteStatus.canceled.label;
  }
  return InviteStatus.pending.label;
}

/// Het rooster in twee delen: wat er nog komt en wat er is geweest.
class RoosterVerdeling {
  const RoosterVerdeling({required this.toekomst, required this.verleden});

  /// Wat nog moet gebeuren of nu bezig is, van eerstvolgend naar verst weg.
  final List<RoosterItem> toekomst;

  /// Wat achter de rug is, van meest recent naar langst geleden. Andersom dan
  /// de toekomst, want bij het verleden is het laatste item het interessantst.
  final List<RoosterItem> verleden;

  bool get isLeeg => toekomst.isEmpty && verleden.isEmpty;
}

/// Sorteert [items] en scheidt verleden van toekomst rond [nu] (FR-13).
///
/// Een item hoort bij het verleden zodra het is afgelopen. Iets dat nu bezig
/// is staat dus bij de toekomst: dat is waar de gebruiker naar kijkt als hij
/// het rooster opent.
RoosterVerdeling verdeelRooster(
  List<RoosterItem> items, {
  required DateTime nu,
}) {
  final toekomst = <RoosterItem>[];
  final verleden = <RoosterItem>[];

  for (final item in items) {
    if (item.eind.isBefore(nu)) {
      verleden.add(item);
    } else {
      toekomst.add(item);
    }
  }

  toekomst.sort(_opStartOplopend);
  verleden.sort((a, b) => _opStartOplopend(b, a));

  return RoosterVerdeling(toekomst: toekomst, verleden: verleden);
}

/// Ontdubbelt matches op id (FR-14). Dezelfde match via twee teams wordt één
/// item, met beide teamnamen. Events blijven ongewijzigd: die horen bij één
/// team en komen uit `GET /events` al zonder dubbelen.
List<RoosterItem> ontdubbelRoosterItems(List<RoosterItem> items) {
  final resultaat = <RoosterItem>[];
  final matchIndex = <int, int>{};

  for (final item in items) {
    if (item.soort != RoosterSoort.match) {
      resultaat.add(item);
      continue;
    }

    final bestaand = matchIndex[item.id];
    if (bestaand == null) {
      matchIndex[item.id] = resultaat.length;
      resultaat.add(item);
    } else {
      resultaat[bestaand] = resultaat[bestaand].metExtraTeamNamen(
        item.teamNamen,
        extraIds: item.teamIds,
      );
    }
  }

  return resultaat;
}

/// Naam van [teamId] in [match], uit het ingebedde `team` of `invites[].team`.
String? matchTeamNaam(Match match, int teamId) {
  if (match.teamId == teamId) return match.team?.name;
  for (final invite in match.invites) {
    if (invite.teamId == teamId) return invite.team?.name;
  }
  return null;
}

/// Op begintijd, en bij een gelijke begintijd op titel. Anders wisselt de orde
/// van twee items op hetzelfde moment per keer dat het rooster wordt opgehaald.
int _opStartOplopend(RoosterItem a, RoosterItem b) {
  final opTijd = a.start.compareTo(b.start);
  return opTijd != 0 ? opTijd : a.titel.compareTo(b.titel);
}
