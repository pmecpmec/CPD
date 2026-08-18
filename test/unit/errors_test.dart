import 'package:crossplatformdevelopment/core/errors.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vertaling van de vier bekende API-teksten. Onbekende teksten blijven staan.
void main() {
  test('Username already taken', () {
    expect(
      vertaalServerFout('Username already taken'),
      'Deze gebruikersnaam is al in gebruik.',
    );
  });

  test('Invalid username or password', () {
    expect(
      vertaalServerFout('Invalid username or password'),
      'Gebruikersnaam of wachtwoord klopt niet.',
    );
  });

  test('Team not found', () {
    expect(
      vertaalServerFout('Team not found'),
      'Dit team bestaat niet of is verwijderd.',
    );
  });

  test('Invalid or expired token', () {
    expect(
      vertaalServerFout('Invalid or expired token'),
      'Je sessie is verlopen. Log opnieuw in.',
    );
  });

  test('onbekende melding blijft onvertaald', () {
    expect(vertaalServerFout('Password too short'), 'Password too short');
  });
}
