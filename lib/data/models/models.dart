/// Datamodellen voor de Team Management API.
///
/// De klassen krijgen het uitgepakte `data`-object binnen; de envelop van de
/// API wordt in `ApiClient` afgehandeld.
///
/// Alle veldnamen hieronder zijn op 12 augustus 2026 tegen de echte API
/// gehouden met `dart run tool/api_verkenning.dart`. De volledige antwoorden
/// staan in `docs/api-waargenomen-gedrag.md`; wijk hier alleen van af na een
/// nieuwe meting.
library;

/// Een gebruiker van de applicatie.
///
/// De API levert een gebruiker alleen als `{"id": 92, "name": "..."}` — in het
/// inlogantwoord met een `token` erbij, in een ledenlijst zonder. Er komt geen
/// rol per gebruiker mee; wie beheerder is, blijkt uit [Team.ownerId].
class User {
  const User({required this.id, required this.name});

  final int id;
  final String name;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: _alsInt(json['id']),
    name: json['name'] as String? ?? 'Onbekend',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// Een team.
///
/// `description` en `metadata` mogen leeg zijn: bij oudere teams staat er
/// `null` in het antwoord. `metadata` is een vrij veld in de API; de app
/// gebruikt het voor een icoonnaam.
class Team {
  const Team({
    required this.id,
    required this.name,
    this.description = '',
    this.ownerId,
    this.metadata = const {},
    this.members = const [],
  });

  final int id;
  final String name;
  final String description;

  /// Gebruikers-id van de beheerder. De API kent geen rol per lid: de eigenaar
  /// is de beheerder en de overige leden zijn gewone leden (FR-06 tot FR-08).
  ///
  /// Kan `null` zijn. In een team dat als bijlage bij `GET /matches/{id}`
  /// meekomt laat de API dit veld weg; alleen `id`, `name` en `members` staan
  /// er dan in. Behandel `null` daarom als "rol onbekend", niet als "geen
  /// beheerder", en haal het team desnoods los op met `GET /teams/{id}`.
  final int? ownerId;

  final Map<String, dynamic> metadata;
  final List<User> members;

  /// Icoonnaam uit metadata, bijvoorbeeld `calendar_today`.
  String? get iconNaam => metadata['Icon'] as String?;

  /// Is [userId] de beheerder van dit team? `false` zolang [ownerId] onbekend
  /// is, zodat een onvolledig antwoord nooit per ongeluk rechten oplevert.
  bool isBeheerder(int? userId) =>
      userId != null && ownerId != null && ownerId == userId;

  /// Hoort [userId] bij dit team? Bepaalt wat er zichtbaar mag zijn (FR-06).
  bool isLid(int? userId) =>
      userId != null && members.any((lid) => lid.id == userId);

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: _alsInt(json['id']),
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    ownerId: _alsIntOfNull(json['ownerId']),
    metadata: _alsMap(json['metadata']),
    members: _alsLijst(json['members']).map(User.fromJson).toList(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'metadata': metadata,
  };
}

/// Locatie van een event of match. De API werkt met coördinaten, niet met
/// adressen — precies wat de routeplanner nodig heeft (FR-17).
class GeoLocatie {
  const GeoLocatie({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  factory GeoLocatie.fromJson(Map<String, dynamic> json) => GeoLocatie(
    latitude: _alsDouble(json['latitude']),
    longitude: _alsDouble(json['longitude']),
  );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

/// Een geplande activiteit van één team.
///
/// De API stuurt het bijbehorende team als [team] mee in hetzelfde antwoord.
/// Voor het persoonlijk rooster (FR-14) is er dus geen extra aanroep nodig om
/// de teamnaam bij een item te zetten.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.teamId,
    this.description = '',
    this.location,
    this.metadata = const {},
    this.team,
  });

  final int id;
  final String title;
  final String description;

  /// Begintijd, omgerekend naar de tijdzone van het apparaat. De API bewaart
  /// en levert UTC (`2026-08-13T13:01:58.000Z`).
  final DateTime start;

  /// Eindtijd, ook lokaal. Zie [start].
  final DateTime end;

  final int teamId;
  final GeoLocatie? location;
  final Map<String, dynamic> metadata;
  final Team? team;

  /// Optionele leesbare plaatsnaam die de app zelf in metadata zet, naast de
  /// coördinaten die de API bewaart.
  String? get locatieNaam => metadata['locatieNaam'] as String?;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: _alsInt(json['id']),
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    start: _alsDatum(json['datetimeStart']),
    end: _alsDatum(json['datetimeEnd']),
    teamId: _alsInt(json['teamId']),
    location: json['location'] is Map
        ? GeoLocatie.fromJson(_alsMap(json['location']))
        : null,
    metadata: _alsMap(json['metadata']),
    team: json['team'] is Map ? Team.fromJson(_alsMap(json['team'])) : null,
  );

  /// De API verwacht UTC bij het aanmaken en wijzigen, en kapt de tijd af op
  /// hele seconden.
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'datetimeStart': start.toUtc().toIso8601String(),
    'datetimeEnd': end.toUtc().toIso8601String(),
    if (location != null) 'location': location!.toJson(),
    'teamId': teamId,
    'metadata': metadata,
  };
}

/// Status van een uitnodiging voor een match.
///
/// Waargenomen waarden: `pending`, `accepted` en `declined`. `canceled` staat
/// in de API-documentatie als overgang vanuit `accepted`, maar kwam in de
/// verkenning niet voor; de app kan hem daarom lezen maar leunt er niet op.
enum InviteStatus {
  pending,
  accepted,
  declined,
  canceled;

  static InviteStatus vanTekst(String? waarde) =>
      switch (waarde?.toLowerCase()) {
        'accepted' => InviteStatus.accepted,
        'declined' => InviteStatus.declined,
        'canceled' || 'cancelled' => InviteStatus.canceled,
        _ => InviteStatus.pending,
      };

  String get label => switch (this) {
    InviteStatus.pending => 'In afwachting',
    InviteStatus.accepted => 'Geaccepteerd',
    InviteStatus.declined => 'Afgewezen',
    InviteStatus.canceled => 'Geannuleerd',
  };
}

/// Eén uitnodiging van een team voor een match.
///
/// De API laat dit object in twee vormen zien, met dezelfde betekenis:
///
/// - **In een match**, onder `invites`: `{"teamId": 305, "status": "pending",
///   "team": {...}}`. Hier zit géén [id] bij.
/// - **In `GET /matches/invites`**, bij het uitgenodigde team:
///   `{"id": 32, "matchId": 33, "status": "pending"}`. Hier zit géén team bij.
///
/// Beide vormen worden door dezelfde [fromJson] gelezen; de velden die de
/// betreffende vorm niet levert blijven `null`. [id] is nodig om te antwoorden
/// met `POST /matches/invites/{id}` (FR-16), en die is alleen via
/// `GET /matches/invites` te krijgen.
class MatchInvite {
  const MatchInvite({
    required this.status,
    this.id,
    this.matchId,
    this.teamId,
    this.team,
  });

  final InviteStatus status;
  final int? id;
  final int? matchId;
  final int? teamId;
  final Team? team;

  /// Naam van het uitgenodigde team, voor zover de API die meestuurt.
  String? get teamNaam => team?.name;

  factory MatchInvite.fromJson(Map<String, dynamic> json) => MatchInvite(
    status: InviteStatus.vanTekst(json['status'] as String?),
    id: _alsIntOfNull(json['id']),
    matchId: _alsIntOfNull(json['matchId']),
    teamId:
        _alsIntOfNull(json['teamId']) ??
        (json['team'] is Map
            ? _alsIntOfNull(_alsMap(json['team'])['id'])
            : null),
    team: json['team'] is Map ? Team.fromJson(_alsMap(json['team'])) : null,
  );
}

/// Een event tussen teams: één team organiseert, de andere worden uitgenodigd.
///
/// De API kent géén status op de match zelf. De status zit per uitnodiging in
/// [invites]; het organiserende team ([teamId]) heeft geen uitnodiging en dus
/// geen status.
class Match {
  const Match({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.teamId,
    this.description = '',
    this.location,
    this.metadata = const {},
    this.team,
    this.invites = const [],
  });

  final int id;
  final String title;
  final String description;

  /// Begin- en eindtijd, lokaal. De API levert UTC; zie [Event.start].
  final DateTime start;
  final DateTime end;

  /// Het organiserende team.
  final int teamId;
  final Team? team;

  final GeoLocatie? location;
  final Map<String, dynamic> metadata;
  final List<MatchInvite> invites;

  /// Alle teams die bij deze match horen: de organisator plus de uitgenodigde
  /// teams. Nodig om in het persoonlijk rooster te bepalen of de gebruiker via
  /// meer dan één team betrokken is (FR-14).
  List<int> get teamIds => [
    teamId,
    ...invites.map((invite) => invite.teamId).whereType<int>(),
  ];

  /// Hebben alle uitgenodigde teams geaccepteerd? Het teamrooster moet dat
  /// tonen (FR-13). Een match zonder uitnodigingen levert `false`: er is dan
  /// niets geaccepteerd om te melden.
  bool get alleGeaccepteerd =>
      invites.isNotEmpty &&
      invites.every((invite) => invite.status == InviteStatus.accepted);

  /// De status van de uitnodiging van [gezochtTeamId], of `null` wanneer dat
  /// team niet is uitgenodigd — bijvoorbeeld omdat het de organisator is.
  InviteStatus? statusVoorTeam(int gezochtTeamId) {
    for (final invite in invites) {
      if (invite.teamId == gezochtTeamId) return invite.status;
    }
    return null;
  }

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: _alsInt(json['id']),
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    start: _alsDatum(json['datetimeStart']),
    end: _alsDatum(json['datetimeEnd']),
    teamId: _alsInt(json['teamId']),
    location: json['location'] is Map
        ? GeoLocatie.fromJson(_alsMap(json['location']))
        : null,
    metadata: _alsMap(json['metadata']),
    team: json['team'] is Map ? Team.fromJson(_alsMap(json['team'])) : null,
    invites: _alsLijst(json['invites']).map(MatchInvite.fromJson).toList(),
  );
}

// --- hulpfuncties ---------------------------------------------------------
// De API is niet altijd consistent: `description` en `metadata` kunnen `null`
// zijn en een team als bijlage mist soms velden. Deze functies vangen dat af
// zodat een afwijking geen crash oplevert maar een lege of standaardwaarde.

int _alsInt(dynamic waarde) => _alsIntOfNull(waarde) ?? 0;

int? _alsIntOfNull(dynamic waarde) => switch (waarde) {
  int v => v,
  String v => int.tryParse(v),
  num v => v.toInt(),
  _ => null,
};

double _alsDouble(dynamic waarde) => switch (waarde) {
  double v => v,
  int v => v.toDouble(),
  String v => double.tryParse(v) ?? 0,
  _ => 0,
};

DateTime _alsDatum(dynamic waarde) {
  if (waarde is String) {
    return DateTime.tryParse(waarde)?.toLocal() ?? DateTime.now();
  }
  return DateTime.now();
}

Map<String, dynamic> _alsMap(dynamic waarde) =>
    waarde is Map ? Map<String, dynamic>.from(waarde) : <String, dynamic>{};

List<Map<String, dynamic>> _alsLijst(dynamic waarde) => waarde is List
    ? waarde.whereType<Map>().map(Map<String, dynamic>.from).toList()
    : <Map<String, dynamic>>[];
