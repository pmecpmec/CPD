import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../shared/formulier_velden.dart';
import 'auth_controller.dart';
import 'register_screen.dart';

/// FR-02 — inloggen met gebruikersnaam en wachtwoord.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeNaam = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formSleutel = GlobalKey<FormState>();
  final _naam = TextEditingController();
  final _wachtwoord = TextEditingController();

  @override
  void dispose() {
    _naam.dispose();
    _wachtwoord.dispose();
    super.dispose();
  }

  Future<void> _verstuur() async {
    if (!_formSleutel.currentState!.validate()) return;
    await context.read<AuthController>().login(
      naam: _naam.text.trim(),
      wachtwoord: _wachtwoord.text,
    );
    // Navigeren gebeurt niet hier: de app luistert naar de sessiestatus en
    // wisselt zelf van scherm zodra het inloggen gelukt is.
  }

  void _naarRegistreren() {
    context.read<AuthController>().wisFout();
    Navigator.of(context).pushNamed(RegisterScreen.routeNaam);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: InhoudBegrenzer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formSleutel,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Teamplanner',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Log in om je teams en agenda te zien',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  if (auth.foutmelding != null) ...[
                    Foutmelding(auth.foutmelding!),
                    const SizedBox(height: 16),
                  ],
                  NaamVeld(controller: _naam, autofocus: true),
                  const SizedBox(height: 16),
                  WachtwoordVeld(
                    controller: _wachtwoord,
                    minimumLengte: 1,
                    onSubmitted: _verstuur,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: auth.bezig ? null : _verstuur,
                    child: auth.bezig
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Inloggen'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: auth.bezig ? null : _naarRegistreren,
                    child: const Text('Nog geen account? Registreren'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
