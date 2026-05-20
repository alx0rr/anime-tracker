import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import 'anime_list_screen.dart';
import 'tags_screen.dart';
import 'settings_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final screens = const [
      AnimeListScreen(),
      TagsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A2E),
        indicatorColor: const Color(0xFF7C3AED).withOpacity(0.3),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.movie_outlined),
            selectedIcon:
                const Icon(Icons.movie, color: Color(0xFF7C3AED)),
            label: s['nav_anime'],
          ),
          NavigationDestination(
            icon: const Icon(Icons.label_outline),
            selectedIcon:
                const Icon(Icons.label, color: Color(0xFF7C3AED)),
            label: s['nav_tags'],
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon:
                const Icon(Icons.settings, color: Color(0xFF7C3AED)),
            label: s['nav_settings'],
          ),
        ],
      ),
    );
  }
}