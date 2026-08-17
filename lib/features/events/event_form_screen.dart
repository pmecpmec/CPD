import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/event_repository.dart';
import '../../shared/datum_tekst.dart';
import '../../shared/formulier_velden.dart';
import 'event_form_controller.dart';

/// FR-11 — een beheerder maakt een event aan voor zijn team.
///
/// Het scherm is alleen bereikbaar vanaf de knop in het teamdetail, en die
/// staat er uitsluitend voor de beheerder. De API bewaakt dat ook zelf: een
/// gewoon lid krijgt een 403, wat als `GeenRechtenException` in beeld komt.
class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key});

  /// Opent het formulier en geeft het aangemaakte event terug, of `null`
  /// wanneer de gebruiker afbrak.
  ///
  /// De controller wordt hier gemaakt omdat hij een team-id nodig heeft en dus
  /// niet in de vaste providers van `main.dart` past.
  static Future<Event?> open(BuildContext context, {required int teamId}) {
    final events = context.read<EventRepository>();

    return Navigator.of(context).push<Event>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) =>
              EventFormController(eventRepository: events, teamId: teamId),
          child: const EventFormScreen(),
        ),
      ),
    );
  }

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formSleutel = GlobalKey<FormState>();
  final _titel = TextEditingController();
  final _beschrijving = TextEditingController();
  final _breedtegraad = TextEditingController();
  final _lengtegraad = TextEditingController();
  final _locatieNaam = TextEditingController();

  @override
  void dispose() {
    _titel.dispose();
    _beschrijving.dispose();
    _breedtegraad.dispose();
    _lengtegraad.dispose();
    _locatieNaam.dispose();
    super.dispose();
  }

  /// Laat de gebruiker een datum en daarna een tijd kiezen. Breekt hij een van
  /// de twee af, dan blijft het bestaande moment staan.
  Future<void> _kiesMoment({required bool isBegin}) async {
    final controller = context.read<EventFormController>();
    final huidig = isBegin ? controller.begin : controller.eind;

    final datum = await showDatePicker(
      context: context,
      initialDate: huidig,
      firstDate: controller.vroegsteDatum,
      lastDate: controller.laatsteDatum,
      helpText: isBegin ? 'Begindatum' : 'Einddatum',
    );
    if (datum == null || !mounted) return;

    final tijd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(huidig),
      helpText: isBegin ? 'Begintijd' : 'Eindtijd',
    );
    if (tijd == null || !mounted) return;

    final moment = DateTime(
      datum.year,
      datum.month,
      datum.day,
      tijd.hour,
      tijd.minute,
    );
    if (isBegin) {
      controller.zetBegin(moment);
    } else {
      controller.zetEind(moment);
    }
  }

  Future<void> _verstuur() async {
    final controller = context.read<EventFormController>();

    // Alles wordt vóór verzending gecontroleerd, zodat er geen verzoek uitgaat
    // dat de server toch weigert (FR-11). De periodefout staat al onder de
    // tijdvelden zodra die ontstaat; hier wordt alleen het versturen
    // tegengehouden.
    final veldenKloppen = _formSleutel.currentState?.validate() ?? false;
    if (!veldenKloppen || controller.periodeFout != null) return;

    final event = await controller.maakEvent(
      titel: _titel.text,
      beschrijving: _beschrijving.text,
      breedtegraad: _breedtegraad.text,
      lengtegraad: _lengtegraad.text,
      locatieNaam: _locatieNaam.text,
    );
    if (!mounted) return;

    if (event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.foutmelding ?? 'Het event kon niet worden aangemaakt.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(event);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventFormController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nieuw event')),
      body: InhoudBegrenzer(
        maxBreedte: 560,
        child: Form(
          key: _formSleutel,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              TextFormField(
                controller: _titel,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Titel'),
                validator: valideerTitel,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _beschrijving,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Omschrijving',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              _MomentKiezer(
                label: 'Begint op',
                moment: controller.begin,
                onKies: () => _kiesMoment(isBegin: true),
              ),
              _MomentKiezer(
                label: 'Eindigt op',
                moment: controller.eind,
                onKies: () => _kiesMoment(isBegin: false),
              ),
              if (controller.periodeFout != null) ...[
                const SizedBox(height: 8),
                Foutmelding(controller.periodeFout!),
              ],
              const SizedBox(height: 24),
              Text('Locatie', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'De API bewaart een locatie als coördinatenpaar, niet als '
                'adres. De plaatsnaam komt erbij te staan, zodat het rooster '
                'niet alleen getallen laat zien.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CoordinaatVeld(
                      controller: _breedtegraad,
                      label: 'Breedtegraad',
                      hint: '52.5168',
                      validator: (waarde) =>
                          valideerBreedtegraad(waarde) ??
                          valideerCoordinatenpaar(waarde, _lengtegraad.text),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CoordinaatVeld(
                      controller: _lengtegraad,
                      label: 'Lengtegraad',
                      hint: '5.4714',
                      validator: (waarde) =>
                          valideerLengtegraad(waarde) ??
                          valideerCoordinatenpaar(_breedtegraad.text, waarde),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locatieNaam,
                decoration: const InputDecoration(
                  labelText: 'Plaatsnaam',
                  hintText: 'Windesheim Almere',
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: controller.bezig ? null : _verstuur,
                icon: controller.bezig
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.event_available_outlined),
                label: const Text('Event aanmaken'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Eén regel met een gekozen datum en tijd, en een knop om die te wijzigen.
class _MomentKiezer extends StatelessWidget {
  const _MomentKiezer({
    required this.label,
    required this.moment,
    required this.onKies,
  });

  final String label;
  final DateTime moment;
  final VoidCallback onKies;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.schedule_outlined),
    title: Text(label, style: Theme.of(context).textTheme.labelMedium),
    subtitle: Text(
      '${datumTekst(moment)}, ${tijdTekst(moment)}',
      style: Theme.of(context).textTheme.bodyLarge,
    ),
    trailing: TextButton(onPressed: onKies, child: const Text('Wijzigen')),
    onTap: onKies,
  );
}

/// Invoerveld voor een coördinaat: een getal dat negatief en gebroken mag zijn.
class _CoordinaatVeld extends StatelessWidget {
  const _CoordinaatVeld({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
    // Op Android biedt het toetsenbord een komma aan en op web typt iedereen
    // een punt; beide worden geaccepteerd en in `leesCoordinaat` gelijkgetrokken.
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\-,.]'))],
    decoration: InputDecoration(labelText: label, hintText: hint),
    validator: validator,
  );
}
