import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/api/api_client.dart';
import 'data/api/token_store.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/repositories/team_repository.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/teams/teams_controller.dart';
import 'features/teams/teams_screen.dart';

void main() {
  runApp(const TeamplannerApp());
}

/// Zet de afhankelijkheden klaar en start de app.
///
/// De opbouw loopt van onder naar boven: opslag, HTTP-laag, repositories,
/// controllers. Elke laag kent alleen de laag eronder, zodat er in tests een
/// andere invulling voor in de plaats kan (NFR-06).
class TeamplannerApp extends StatelessWidget {
  const TeamplannerApp({super.key, this.tokenStore});

  /// Kan in tests overschreven worden met [GeheugenTokenStore].
  final TokenStore? tokenStore;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TokenStore>(create: (_) => tokenStore ?? SecureTokenStore()),
        Provider<ApiClient>(
          create: (context) =>
              ApiClient(tokenStore: context.read<TokenStore>()),
          dispose: (_, client) => client.sluit(),
        ),
        Provider<AuthRepository>(
          create: (context) => ApiAuthRepository(
            client: context.read<ApiClient>(),
            tokenStore: context.read<TokenStore>(),
          ),
        ),
        Provider<TeamRepository>(
          create: (context) => ApiTeamRepository(context.read<ApiClient>()),
        ),
        Provider<EventRepository>(
          create: (context) => ApiEventRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) {
            final controller = AuthController(context.read<AuthRepository>());
            // De ApiClient meldt hier een verlopen sessie, waarna de app
            // vanzelf terugvalt op het inlogscherm (FR-03).
            context.read<ApiClient>().bijSessieVerlopen =
                controller.sessieVerlopen;
            controller.herstelSessie();
            return controller;
          },
        ),
        ChangeNotifierProvider<TeamsController>(
          create: (context) => TeamsController(context.read<TeamRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Teamplanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.licht(),
        darkTheme: AppTheme.donker(),
        routes: {
          LoginScreen.routeNaam: (_) => const LoginScreen(),
          RegisterScreen.routeNaam: (_) => const RegisterScreen(),
          TeamsScreen.routeNaam: (_) => const TeamsScreen(),
        },
        home: const _Startpunt(),
      ),
    );
  }
}

/// Bepaalt op basis van de sessiestatus welk scherm de gebruiker ziet.
class _Startpunt extends StatelessWidget {
  const _Startpunt();

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthController, SessieStatus>(
      (c) => c.status,
    );

    return switch (status) {
      SessieStatus.onbekend => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      SessieStatus.uitgelogd => const LoginScreen(),
      SessieStatus.ingelogd => const TeamsScreen(),
    };
  }
}
