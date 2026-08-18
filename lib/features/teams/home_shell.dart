import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../schedule/my_schedule_controller.dart';
import '../schedule/my_schedule_screen.dart';
import 'teams_screen.dart';

/// Hoofdnavigatie met tabbladen Teams en Agenda (FR-14, NFR-01).
///
/// Op een smal scherm een [NavigationBar] onderaan, op een breed scherm een
/// [NavigationRail] links. De grens is [breekpunt] logische pixels, zodat de
/// vorm op web wisselt bij het verslepen van het venster.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Breedte vanaf waar de rail verschijnt in plaats van de balk.
  static const double breekpunt = 600;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _bestemmingenBalk = [
    NavigationDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: 'Teams',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Agenda',
    ),
  ];

  static const _bestemmingenRail = [
    NavigationRailDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: Text('Teams'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: Text('Agenda'),
    ),
  ];

  /// IndexedStack houdt beide schermen in leven, dus [MyScheduleScreen.initState]
  /// draait maar één keer. Bij een wissel naar Agenda opnieuw laden (FR-14).
  void _kiesBestemming(int index) {
    setState(() => _index = index);
    if (index == 1) {
      context.read<MyScheduleController>().laad();
    }
  }

  @override
  Widget build(BuildContext context) {
    final breed = MediaQuery.sizeOf(context).width >= HomeShell.breekpunt;
    final inhoud = IndexedStack(
      index: _index,
      children: const [TeamsScreen(), MyScheduleScreen()],
    );

    if (breed) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _kiesBestemming,
              labelType: NavigationRailLabelType.all,
              destinations: _bestemmingenRail,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: inhoud),
          ],
        ),
      );
    }

    return Scaffold(
      body: inhoud,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _kiesBestemming,
        destinations: _bestemmingenBalk,
      ),
    );
  }
}
