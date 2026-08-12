import '../api/api_client.dart';
import '../models/models.dart';

/// Toegang tot events (basis voor FR-11 tot en met FR-14).
///
/// Let op bij [haalEvents]: de API kent geen endpoint per team en geen endpoint
/// voor het persoonlijk rooster. `GET /events` levert de events van álle teams
/// waar de gebruiker lid van is; het onderscheid tussen teamrooster (FR-13) en
/// persoonlijk rooster (FR-14) maakt de app zelf op basis van `Event.teamId`.
abstract interface class EventRepository {
  Future<List<Event>> haalEvents();
  Future<Event> haalEvent(int id);
  Future<Event> maakEvent({
    required int teamId,
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving,
    GeoLocatie? locatie,
    String? locatieNaam,
  });
  Future<Event> wijzigEvent(
    int id, {
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving,
    GeoLocatie? locatie,
    String? locatieNaam,
    int? teamId,
  });
  Future<void> verwijderEvent(int id);
}

class ApiEventRepository implements EventRepository {
  ApiEventRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Event>> haalEvents() async {
    // De ApiClient pakt de envelop uit, dus hier komt de lijst rechtstreeks.
    final antwoord = await _client.get('/events');
    if (antwoord is! List) return const [];
    return antwoord
        .whereType<Map>()
        .map((e) => Event.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<Event> haalEvent(int id) async {
    final antwoord = await _client.get('/events/$id');
    return Event.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }

  @override
  Future<Event> maakEvent({
    required int teamId,
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving = '',
    GeoLocatie? locatie,
    String? locatieNaam,
  }) async {
    final antwoord = await _client.post(
      '/events',
      body: _body(
        titel: titel,
        start: start,
        eind: eind,
        beschrijving: beschrijving,
        locatie: locatie,
        locatieNaam: locatieNaam,
        teamId: teamId,
      ),
    );
    return Event.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }

  @override
  Future<Event> wijzigEvent(
    int id, {
    required String titel,
    required DateTime start,
    required DateTime eind,
    String beschrijving = '',
    GeoLocatie? locatie,
    String? locatieNaam,
    int? teamId,
  }) async {
    final antwoord = await _client.put(
      '/events/$id',
      body: _body(
        titel: titel,
        start: start,
        eind: eind,
        beschrijving: beschrijving,
        locatie: locatie,
        locatieNaam: locatieNaam,
        teamId: teamId,
      ),
    );
    return Event.fromJson(Map<String, dynamic>.from(antwoord as Map));
  }

  @override
  Future<void> verwijderEvent(int id) => _client.delete('/events/$id');

  /// Bouwt de body voor aanmaken en bijwerken.
  ///
  /// Twee dingen die de API voorschrijft: tijden gaan als UTC in ISO-8601 de
  /// deur uit, en de locatie is een coördinatenpaar en geen adres. Een
  /// leesbare plaatsnaam hoort daarom in het vrije `metadata`-veld, naast de
  /// coördinaten — zie `Event.locatieNaam`.
  Map<String, dynamic> _body({
    required String titel,
    required DateTime start,
    required DateTime eind,
    required String beschrijving,
    required GeoLocatie? locatie,
    required String? locatieNaam,
    required int? teamId,
  }) => {
    'title': titel,
    'description': beschrijving,
    'datetimeStart': start.toUtc().toIso8601String(),
    'datetimeEnd': eind.toUtc().toIso8601String(),
    if (locatie != null) 'location': locatie.toJson(),
    'teamId': ?teamId,
    'metadata': {'locatieNaam': ?locatieNaam},
  };
}
