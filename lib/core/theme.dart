import 'package:flutter/material.dart';

/// Eén centraal thema, zodat schermen geen eigen kleuren of lettergroottes
/// vastleggen. Dat houdt het uiterlijk gelijk op web en Android (NFR-05).
class AppTheme {
  const AppTheme._();

  static const Color _basisKleur = Color(0xFF1B5E9E);

  static ThemeData licht() {
    final schema = ColorScheme.fromSeed(seedColor: _basisKleur);
    return _bouw(schema);
  }

  static ThemeData donker() {
    final schema = ColorScheme.fromSeed(
      seedColor: _basisKleur,
      brightness: Brightness.dark,
    );
    return _bouw(schema);
  }

  static ThemeData _bouw(ColorScheme schema) => ThemeData(
    colorScheme: schema,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: schema.surfaceContainer,
      centerTitle: false,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
  );

  /// Maximale breedte van de inhoud. Zonder deze grens rekt een formulier op
  /// een breed scherm uit tot een onbruikbare band tekst — het verschil tussen
  /// "draait op web" en "werkt op web".
  static const double maxInhoudBreedte = 520;
}

/// Houdt de inhoud gecentreerd en beperkt van breedte op grote schermen.
class InhoudBegrenzer extends StatelessWidget {
  const InhoudBegrenzer({
    super.key,
    required this.child,
    this.maxBreedte = AppTheme.maxInhoudBreedte,
  });

  final Widget child;
  final double maxBreedte;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxBreedte),
      child: child,
    ),
  );
}
