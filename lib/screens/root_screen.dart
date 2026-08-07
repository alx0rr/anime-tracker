import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import 'anime_list_screen.dart';
import 'tags_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

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
      StatisticsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: screens[_index],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            );
          }),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF1A1A2E),
          indicatorColor: const Color(0xFF7C3AED).withOpacity(0.2),
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.movie_filter_outlined, color: Colors.white54),
              selectedIcon:
                  const Icon(Icons.movie_filter_rounded, color: Color(0xFF7C3AED)),
              label: s['nav_anime'],
            ),
            NavigationDestination(
              icon: const Icon(Icons.style_outlined, color: Colors.white54),
              selectedIcon:
                  const Icon(Icons.style_rounded, color: Color(0xFF7C3AED)),
              label: s['nav_tags'],
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined, color: Colors.white54),
              selectedIcon:
                  const Icon(Icons.insights_rounded, color: Color(0xFF7C3AED)),
              label: s['nav_statistics'],
            ),
            NavigationDestination(
              icon: const Icon(Icons.tune_outlined, color: Colors.white54),
              selectedIcon:
                  const Icon(Icons.tune_rounded, color: Color(0xFF7C3AED)),
              label: s['nav_settings'],
            ),
          ],
        ),
      ),
    );
  }
}