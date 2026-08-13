/// Centrale configuratie van de applicatie.
///
/// De basis-URL staat hier en nergens anders, zodat er in tests of bij een
/// andere omgeving maar één plek gewijzigd hoeft te worden.
class AppConfig {
  const AppConfig._();

  /// Basis-URL van de Team Management API, versie 2.
  static const String apiBaseUrl =
      'https://team-managment-api.dendrowen.com/api/v2';

  /// Maximale wachttijd op een antwoord van de server.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Sleutel waaronder het toegangstoken veilig wordt opgeslagen.
  static const String tokenStorageKey = 'auth_token';

  /// Sleutel waaronder het id van de ingelogde gebruiker wordt opgeslagen.
  static const String userIdStorageKey = 'user_id';
}

/// De vorm van de QR-uitnodiging waarmee iemand lid wordt van een team
/// (FR-09 en FR-10).
///
/// De API kent geen uitnodigings-endpoint: de code is volledig van de app zelf.
/// Er staat daarom niet meer in dan het team-id, in de vorm
/// `teamplanner:team:42`. De beheerder toont die code, de scanner leest hem en
/// voegt zichzelf toe met `POST /teams/{id}/addUser`.
///
/// Tonen en scannen gebruiken dezelfde twee functies, zodat de vorm maar op één
/// plek vastligt: [bouwCode] schrijft hem, [leesTeamId] leest hem terug.
class TeamUitnodiging {
  const TeamUitnodiging._();

  /// Naam van de app in de code. Zonder dit voorvoegsel is een willekeurige
  /// QR-code op een poster niet te onderscheiden van een uitnodiging.
  static const String schema = 'teamplanner';

  /// Waar de code over gaat. Ligt vast, maar maakt ruimte voor een andere
  /// soort code zonder dat het formaat onherkenbaar wordt.
  static const String soort = 'team';

  /// Alles vóór het team-id: `teamplanner:team:`.
  static const String voorvoegsel = '$schema:$soort:';

  /// Bouwt de inhoud van de QR-code voor [teamId] (FR-09).
  static String bouwCode(int teamId) => '$voorvoegsel$teamId';

  /// Haalt het team-id uit een gescande [code], of geeft `null` wanneer het
  /// geen uitnodiging van deze app is (FR-10).
  ///
  /// Een scanner levert alles op wat hij tegenkomt — een website, een
  /// wifi-code, een pakketlabel. Alleen een code die precies aan het formaat
  /// voldoet en een positief team-id bevat, komt er hier doorheen.
  static int? leesTeamId(String? code) {
    final opgeschoond = code?.trim() ?? '';
    if (!opgeschoond.toLowerCase().startsWith(voorvoegsel)) return null;

    final staart = opgeschoond.substring(voorvoegsel.length);
    // Alleen cijfers: zo vallen "+42", "42 " en "42:extra" af, en levert een
    // te groot getal geen uitzondering op maar `null`.
    if (!_alleenCijfers.hasMatch(staart)) return null;

    final teamId = int.tryParse(staart);
    if (teamId == null || teamId <= 0) return null;
    return teamId;
  }

  static final RegExp _alleenCijfers = RegExp(r'^\d+$');
}
