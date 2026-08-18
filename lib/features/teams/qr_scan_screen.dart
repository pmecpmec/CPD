import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/team_repository.dart';
import 'qr_scan_controller.dart';

/// Tekst bij een code die niet het afgesproken formaat heeft. Geen fout van
/// de server: de scanner blijft open (FR-10).
const qrOngeldigeCodeMelding = 'Deze code is geen teamuitnodiging.';

/// Bevestiging nadat de gebruiker lid is geworden.
String qrToegevoegdMelding(String teamNaam) =>
    'Je bent nu lid van "$teamNaam".';

/// Bevestiging wanneer een tweede scan hetzelfde team raakt.
String qrAlLidMelding(String teamNaam) => 'Je bent al lid van "$teamNaam".';

/// FR-10 — scant een QR-uitnodiging en voegt de ingelogde gebruiker toe.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({
    super.key,
    this.cameraGeweigerd = false,
    this.openInstellingen,
  });

  /// Alleen voor tests: sla de echte camera over en toon de uitleg.
  final bool cameraGeweigerd;

  /// Opent de systeeminstellingen. In productie [openCameraInstellingen].
  final Future<void> Function()? openInstellingen;

  /// Opent de scanner. Geeft een resultaat terug bij lid worden of al-lid,
  /// of `null` wanneer de gebruiker afbreekt. Ongeldige codes blijven op
  /// dit scherm.
  static Future<QrScanVerwerking?> open(BuildContext context) {
    final teams = context.read<TeamRepository>();
    final auth = context.read<AuthRepository>();

    return Navigator.of(context).push<QrScanVerwerking>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) =>
              QrScanController(teamRepository: teams, authRepository: auth),
          child: const QrScanScreen(),
        ),
      ),
    );
  }

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  MobileScannerController? _scanner;
  DateTime? _laatsteOngeldigeMelding;

  @override
  void initState() {
    super.initState();
    if (!widget.cameraGeweigerd) {
      _scanner = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
    }
  }

  @override
  void dispose() {
    _scanner?.dispose();
    super.dispose();
  }

  Future<void> _openInstellingen() async {
    final extra = widget.openInstellingen;
    if (extra != null) {
      await extra();
      return;
    }
    await openCameraInstellingen();
  }

  void _toonMelding(String tekst) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(tekst)));
  }

  Future<void> _bijDetectie(BarcodeCapture capture) async {
    final controller = context.read<QrScanController>();
    if (controller.bezig) return;

    final code = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;

    // Ongeldig formaat: melding, scanner blijft lopen (FR-10).
    if (TeamUitnodiging.leesTeamId(code) == null) {
      final nu = DateTime.now();
      final vorige = _laatsteOngeldigeMelding;
      if (vorige != null &&
          nu.difference(vorige) < const Duration(seconds: 2)) {
        return;
      }
      _laatsteOngeldigeMelding = nu;
      _toonMelding(qrOngeldigeCodeMelding);
      return;
    }

    await _scanner?.stop();
    final verwerking = await controller.verwerkCode(code);
    if (!mounted) return;

    switch (verwerking) {
      case QrScanOngeldigeCode():
        _toonMelding(qrOngeldigeCodeMelding);
        await _scanner?.start();
      case QrScanNietGevonden():
        _toonMelding(verwerking.melding);
        await _scanner?.start();
      case QrScanMislukt():
        _toonMelding(verwerking.melding);
        await _scanner?.start();
      case QrScanAlLid() || QrScanToegevoegd():
        Navigator.of(context).pop(verwerking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR-code scannen')),
      body: widget.cameraGeweigerd
          ? _ToestemmingUitleg(onInstellingen: _openInstellingen)
          : MobileScanner(
              controller: _scanner,
              onDetect: _bijDetectie,
              errorBuilder: (context, error) {
                if (error.errorCode ==
                    MobileScannerErrorCode.permissionDenied) {
                  return _ToestemmingUitleg(onInstellingen: _openInstellingen);
                }
                return _CameraFout(error: error);
              },
            ),
    );
  }
}

/// Uitleg wanneer de camera is geweigerd, met een knop naar de instellingen.
class _ToestemmingUitleg extends StatelessWidget {
  const _ToestemmingUitleg({required this.onInstellingen});

  final Future<void> Function() onInstellingen;

  @override
  Widget build(BuildContext context) {
    return InhoudBegrenzer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera niet beschikbaar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'De app heeft toegang tot de camera nodig om een uitnodiging te '
              'scannen. Je kunt dat in de instellingen alsnog toestaan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onInstellingen,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Instellingen'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Andere camerafout dan een geweigerde toestemming, bijvoorbeeld geen camera.
class _CameraFout extends StatelessWidget {
  const _CameraFout({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final tekst = error.errorCode == MobileScannerErrorCode.unsupported
        ? 'De camera is op dit apparaat niet beschikbaar.'
        : 'De camera kon niet worden gestart.';

    return InhoudBegrenzer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(tekst, textAlign: TextAlign.center)),
      ),
    );
  }
}

/// Opent de app-instellingen zodat de gebruiker de camera alsnog kan toestaan.
///
/// Op web bestaat dat scherm niet: de browser houdt cameratoestemming zelf bij.
Future<void> openCameraInstellingen() async {
  if (kIsWeb) return;
  await openAppSettings();
}
