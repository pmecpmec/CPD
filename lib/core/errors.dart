/// Foutmodellen voor de datalaag.
///
/// De ApiClient vertaalt HTTP-statuscodes en netwerkfouten naar deze klassen,
/// zodat schermen nooit met ruwe statuscodes hoeven te werken. Elke fout draagt
/// een [bericht] dat direct aan de gebruiker getoond kan worden (NFR-03).
sealed class AppException implements Exception {
  const AppException(this.bericht);

  final String bericht;

  @override
  String toString() => '$runtimeType: $bericht';
}

/// Er kon geen verbinding met de server gemaakt worden, of de server
/// antwoordde niet binnen de ingestelde tijd.
class NetwerkException extends AppException {
  const NetwerkException([
    super.bericht =
        'Geen verbinding met de server. Controleer je internetverbinding.',
  ]);
}

/// De sessie is verlopen of ontbreekt. De app hoort de gebruiker hierna terug
/// te sturen naar het inlogscherm (FR-03).
class SessieVerlopenException extends AppException {
  const SessieVerlopenException([
    super.bericht = 'Je sessie is verlopen. Log opnieuw in.',
  ]);
}

/// De inloggegevens klopten niet.
class OngeldigeInlogException extends AppException {
  const OngeldigeInlogException([
    super.bericht = 'Gebruikersnaam of wachtwoord klopt niet.',
  ]);
}

/// De server wees het verzoek af, bijvoorbeeld omdat de invoer niet voldeed.
class ValidatieException extends AppException {
  const ValidatieException(super.bericht);
}

/// De gebruiker heeft geen rechten voor deze actie (FR-06).
class GeenRechtenException extends AppException {
  const GeenRechtenException([
    super.bericht = 'Je hebt geen rechten voor deze actie.',
  ]);
}

/// Het gevraagde item bestaat niet.
class NietGevondenException extends AppException {
  const NietGevondenException([
    super.bericht = 'Dit item bestaat niet of is verwijderd.',
  ]);
}

/// Er ging iets mis aan de kant van de server.
class ServerException extends AppException {
  const ServerException([
    super.bericht = 'Er ging iets mis op de server. Probeer het later opnieuw.',
  ]);
}

/// Vertaalt bekende serverteksten naar het Nederlands (NFR-03).
/// Onbekende teksten blijven ongewijzigd.
String vertaalServerFout(String melding) {
  const bekend = {
    'Username already taken': 'Deze gebruikersnaam is al in gebruik.',
    'Invalid username or password': 'Gebruikersnaam of wachtwoord klopt niet.',
    'Team not found': 'Dit team bestaat niet of is verwijderd.',
    'Invalid or expired token': 'Je sessie is verlopen. Log opnieuw in.',
  };
  return bekend[melding] ?? melding;
}
