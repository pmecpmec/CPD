import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../shared/formulier_velden.dart';
import 'auth_controller.dart';

/// FR-01 — registreren met gebruikersnaam en wachtwoord.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeNaam = '/registreren';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formSleutel = GlobalKey<FormState>();
  final _naam = TextEditingController();
  final _wachtwoord = TextEditingController();
  final _herhaling = TextEditingController();

  @override
  void dispose() {
    _naam.dispose();
    _wachtwoord.dispose();
    _herhaling.dispose();
    super.dispose();
  }

  Future<void> _verstuur() async {
    if (!_formSleutel.currentState!.validate()) return;
    final gelukt = await context.read<AuthController>().registreer(
      naam: _naam.text.trim(),
      wachtwoord: _wachtwoord.text,
    );
    // Mislukt het, dan blijft de gebruiker hier staan met de melding in beeld.
    // Lukt het wel, dan is hij ook ingelogd en verlaten we dit scherm.
    if (gelukt && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Account aanmaken')),
      body: SafeArea(
        child: InhoudBegrenzer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formSleutel,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (auth.foutmelding != null) ...[
                    Foutmelding(auth.foutmelding!),
                    const SizedBox(height: 16),
                  ],
                  NaamVeld(controller: _naam, autofocus: true),
                  const SizedBox(height: 16),
                  WachtwoordVeld(controller: _wachtwoord),
                  const SizedBox(height: 16),
                  WachtwoordVeld(
                    controller: _herhaling,
                    label: 'Wachtwoord herhalen',
                    onSubmitted: _verstuur,
                    extraValidatie: (waarde) => waarde == _wachtwoord.text
                        ? null
                        : 'De wachtwoorden komen niet overeen.',
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
                        : const Text('Account aanmaken'),
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
