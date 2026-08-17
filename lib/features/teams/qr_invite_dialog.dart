import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/config.dart';

/// FR-09 — de QR-uitnodiging van een team.
///
/// De code bevat alleen het team-id, in de vorm die [TeamUitnodiging] vastlegt.
/// Wie hem scant voegt zichzelf toe aan het team (FR-10); het scherm hoeft
/// daarvoor niets van de API te weten en haalt dus ook niets op.
class QrInviteDialog extends StatelessWidget {
  const QrInviteDialog({
    super.key,
    required this.teamId,
    required this.teamNaam,
  });

  /// Zijde van de code zelf. De opdracht vraagt minimaal 240 logische pixels,
  /// zodat een telefooncamera hem van een laptopscherm kan lezen.
  static const double codeGrootte = 240;

  /// Witte rand rondom de code. Een QR-code heeft een stille zone nodig om
  /// herkend te worden, en die moet ook op een donker thema wit blijven.
  static const double marge = 16;

  final int teamId;
  final String teamNaam;

  /// Toont de uitnodiging als dialoog boven het huidige scherm.
  static Future<void> toon(
    BuildContext context, {
    required int teamId,
    required String teamNaam,
  }) => showDialog<void>(
    context: context,
    builder: (_) => QrInviteDialog(teamId: teamId, teamNaam: teamNaam),
  );

  @override
  Widget build(BuildContext context) {
    final code = TeamUitnodiging.bouwCode(teamId);
    final tekst = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('QR-uitnodiging'),
      // Een vaste breedte, en de inhoud zelf scrollend: `AlertDialog`
      // (scrollable: true) meet zijn inhoud met een intrinsieke breedte, en
      // daar loopt de LayoutBuilder in QrImageView op stuk.
      content: SizedBox(
        width: codeGrootte + 2 * marge,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Laat een teamgenoot deze code scannen om lid te worden van '
                '"$teamNaam".',
                style: tekst.bodyMedium,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(marge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: code,
                  size: codeGrootte,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  // Niveau L is de standaard en het zuinigst met ruimte; M
                  // houdt de code leesbaar als een deel wegvalt door reflectie
                  // op een scherm.
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  semanticsLabel: 'QR-uitnodiging voor $teamNaam',
                ),
              ),
              const SizedBox(height: 12),
              Text(code, style: tekst.bodySmall),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Sluiten'),
        ),
      ],
    );
  }
}
