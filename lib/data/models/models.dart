/// Datamodellen voor de Team Management API.
///
/// LET OP — de veldnamen hieronder zijn afgeleid van de OpenAPI-documentatie en
/// zijn nog niet tegen een echt antwoord gecontroleerd. Draai de stappen uit
/// `SPRINT-1.md`, paragraaf 1, en corrigeer daarna deze klassen. Zolang dat niet
/// is gebeurd, staat er bij elk onzeker veld een opmerking.
library;

/// Een gebruiker van de applicatie.
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

/// Een team. `metadata` is een vrij veld in de API; de app gebruikt het voor
/// een icoonnaam.
class Team {
  const Team({
    required this.id,
    required this.name,
    this.description = '',
    this.metadata = const {},
    this.members = const [],
  });

  final int id;
  final String name;
  final String description;
  final Map<String, dynamic> metadata;
  final List<User> members;

  /// Icoonnaam uit metadata, bijvoorbeeld `calendar_today`.
  String? get iconNaam => metadata['Icon'] as String?;

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: _alsInt(json['id']),
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    metadata: _alsMap(json['metadata']),
    // Onzeker: de sleutel kan ook `members` of `teamUsers` heten. Verifiëren.
    members: _alsLijst(json['users'] ?? json['members'])
        .map(User.fromJson)
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'metadata': metadata,
  };
}

/// Locatie van een event. De API werkt met coördinaten, niet met adressen.
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
  });

  final int id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final int teamId;
  final GeoLocatie? location;
  final Map<String, dynamic> metadata;

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
  );

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

/// Status van een uitnodiging voor een match, zoals de API die kent.
enum InviteStatus {
  pending,
  accepted,
  declined,
  canceled;

  static InviteStatus vanTekst(String? waarde) => switch (waarde?.toLowerCase()) {
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

/// Een wedstrijd of afspraak tussen twee teams.
class Match {
  const Match({
    required this.id,
    required this.title,
    required this.start,
    required this.status,
    this.description = '',
    this.location,
    this.teamIds = const [],
  });

  final int id;
  final String title;
  final String description;
  final DateTime start;
  final InviteStatus status;
  final GeoLocatie? location;
  final List<int> teamIds;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: _alsInt(json['id']),
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    start: _alsDatum(json['datetimeStart']),
    status: InviteStatus.vanTekst(json['status'] as String?),
    location: json['location'] is Map
        ? GeoLocatie.fromJson(_alsMap(json['location']))
        : null,
    // Onzeker: mogelijk heten deze velden `homeTeamId` en `awayTeamId`.
    teamIds: _alsLijst(json['teams'])
        .map((t) => _alsInt(t['id']))
        .toList(),
  );
}

// --- hulpfuncties ---------------------------------------------------------
// De API is niet altijd consistent in types; deze functies vangen dat af zodat
// een afwijking geen crash oplevert maar een lege of standaardwaarde.

int _alsInt(dynamic waarde) => switch (waarde) {
  int v => v,
  String v => int.tryParse(v) ?? 0,
  num v => v.toInt(),
  _ => 0,
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
