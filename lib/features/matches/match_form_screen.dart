import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/errors.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/team_repository.dart';
import '../../shared/datum_tekst.dart';
import '../../shared/formulier_velden.dart';
import '../events/event_form_controller.dart';
import 'match_form_controller.dart';

/// FR-15 — een beheerder maakt een match aan.
class MatchFormScreen extends StatefulWidget {
  const MatchFormScreen({super.key});

  static Future<Match?> open(BuildContext context, {int? teamId}) {
    final matches = context.read<MatchRepository>();
    final teams = context.read<TeamRepository>();
    final auth = context.read<AuthRepository>();

    return Navigator.of(context).push<Match>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MatchFormController(
            matchRepository: matches,
            teamRepository: teams,
            authRepository: auth,
            teamId: teamId,
          ),
          child: const MatchFormScreen(),
        ),
      ),
    );
  }

  @override
  State<MatchFormScreen> createState() => _MatchFormScreenState();
}

class _MatchFormScreenState extends State<MatchFormScreen> {
  final _formSleutel = GlobalKey<FormState>();
  final _titel = TextEditingController();
  final _beschrijving = TextEditingController();
  final _breedtegraad = TextEditingController();
  final _lengtegraad = TextEditingController();
  final _locatieNaam = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MatchFormController>().laad(),
    );
  }

  @override
  void dispose() {
    _titel.dispose();
    _beschrijving.dispose();
    _breedtegraad.dispose();
    _lengtegraad.dispose();
    _locatieNaam.dispose();
    super.dispose();
  }

  Future<void> _kiesMoment({required bool isBegin}) async {
    final controller = context.read<MatchFormController>();
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
    final controller = context.read<MatchFormController>();
    final veldenKloppen = _formSleutel.currentState?.validate() ?? false;
    if (!veldenKloppen || controller.periodeFout != null) return;

    final match = await controller.maakMatch(
      titel: _titel.text,
      beschrijving: _beschrijving.text,
      breedtegraad: _breedtegraad.text,
      lengtegraad: _lengtegraad.text,
      locatieNaam: _locatieNaam.text,
    );
    if (!mounted) return;

    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.foutmelding ?? const ServerException().bericht,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(match);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MatchFormController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nieuwe match')),
      body: InhoudBegrenzer(
        maxBreedte: 560,
        child: controller.laadt
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formSleutel,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    if (controller.foutmelding != null) ...[
                      Foutmelding(controller.foutmelding!),
                      const SizedBox(height: 16),
                    ],
                    if (controller.beheerTeams.length > 1) ...[
                      DropdownButtonFormField<int>(
                        key: ValueKey(controller.teamId),
                        initialValue: controller.teamId,
                        decoration: const InputDecoration(
                          labelText: 'Jouw team',
                        ),
                        items: [
                          for (final team in controller.beheerTeams)
                            DropdownMenuItem(
                              value: team.id,
                              child: Text(team.name),
                            ),
                        ],
                        onChanged: controller.bezig
                            ? null
                            : (waarde) {
                                if (waarde != null) controller.zetTeam(waarde);
                              },
                      ),
                      const SizedBox(height: 16),
                    ],
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
                    Text(
                      'Uitgenodigde teams',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Een match gaat pas door als het andere team accepteert.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    for (final team in controller.andereTeams)
                      CheckboxListTile(
                        value: controller.uitgenodigd.contains(team.id),
                        title: Text(team.name),
                        subtitle: team.description.isEmpty
                            ? null
                            : Text(team.description),
                        contentPadding: EdgeInsets.zero,
                        onChanged: controller.bezig
                            ? null
                            : (gekozen) => controller.zetUitnodiging(
                                team.id,
                                gekozen ?? false,
                              ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Locatie',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _breedtegraad,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d\-,.]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Breedtegraad',
                              hintText: '52.5168',
                            ),
                            validator: (waarde) =>
                                valideerBreedtegraad(waarde) ??
                                valideerCoordinatenpaar(
                                  waarde,
                                  _lengtegraad.text,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lengtegraad,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d\-,.]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Lengtegraad',
                              hintText: '5.4714',
                            ),
                            validator: (waarde) =>
                                valideerLengtegraad(waarde) ??
                                valideerCoordinatenpaar(
                                  _breedtegraad.text,
                                  waarde,
                                ),
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
                          : const Icon(Icons.sports_outlined),
                      label: const Text('Match aanmaken'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

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
