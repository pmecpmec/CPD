import 'package:flutter/material.dart';

/// Invoerveld voor een gebruikersnaam.
class NaamVeld extends StatelessWidget {
  const NaamVeld({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    autofocus: autofocus,
    textInputAction: TextInputAction.next,
    autofillHints: const [AutofillHints.username],
    decoration: const InputDecoration(
      labelText: 'Gebruikersnaam',
      prefixIcon: Icon(Icons.person_outline),
    ),
    validator: (waarde) {
      final naam = waarde?.trim() ?? '';
      if (naam.isEmpty) return 'Vul een gebruikersnaam in.';
      if (naam.length < 3) return 'Gebruik minimaal drie tekens.';
      return null;
    },
    onFieldSubmitted: (_) => onSubmitted?.call(),
  );
}

/// Invoerveld voor een wachtwoord, met een knop om het zichtbaar te maken.
class WachtwoordVeld extends StatefulWidget {
  const WachtwoordVeld({
    super.key,
    required this.controller,
    this.label = 'Wachtwoord',
    this.minimumLengte = 8,
    this.onSubmitted,
    this.extraValidatie,
  });

  final TextEditingController controller;
  final String label;
  final int minimumLengte;
  final VoidCallback? onSubmitted;
  final String? Function(String waarde)? extraValidatie;

  @override
  State<WachtwoordVeld> createState() => _WachtwoordVeldState();
}

class _WachtwoordVeldState extends State<WachtwoordVeld> {
  bool _verborgen = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: _verborgen,
    textInputAction: TextInputAction.done,
    autofillHints: const [AutofillHints.password],
    decoration: InputDecoration(
      labelText: widget.label,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(_verborgen ? Icons.visibility_off : Icons.visibility),
        tooltip: _verborgen ? 'Wachtwoord tonen' : 'Wachtwoord verbergen',
        onPressed: () => setState(() => _verborgen = !_verborgen),
      ),
    ),
    validator: (waarde) {
      final wachtwoord = waarde ?? '';
      if (wachtwoord.isEmpty) return 'Vul een wachtwoord in.';
      if (wachtwoord.length < widget.minimumLengte) {
        return 'Gebruik minimaal ${widget.minimumLengte} tekens.';
      }
      return widget.extraValidatie?.call(wachtwoord);
    },
    onFieldSubmitted: (_) => widget.onSubmitted?.call(),
  );
}

/// Meldingsbalk voor een fout die van de server of de validatie komt.
class Foutmelding extends StatelessWidget {
  const Foutmelding(this.tekst, {super.key});

  final String tekst;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: schema.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: schema.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tekst,
              style: TextStyle(color: schema.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
