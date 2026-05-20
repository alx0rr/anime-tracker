import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/strings.dart';
import 'store/store_provider.dart';
import 'screens/root_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('locale') ?? 'ru';
  runApp(AnimeTrackerApp(initialLocale: savedLocale));
}

class AnimeTrackerApp extends StatelessWidget {
  final String initialLocale;
  const AnimeTrackerApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return L10nProvider(
      initialLocale: initialLocale,
      child: StoreProvider(
        child: Builder(
          builder: (ctx) => MaterialApp(
            title: 'Anime Tracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF0D0D1A),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF7C3AED),
                surface: Color(0xFF1A1A2E),
              ),
            ),
            home: const RootScreen(),
          ),
        ),
      ),
    );
  }
}