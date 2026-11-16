import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/strings.dart';
import 'store/store.dart';
import 'store/store_provider.dart';
import 'screens/root_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('locale') ?? 'ru';
  final themeMode = prefs.getString(Store.themeModeKey) ?? 'dark';
  final viewGrid = prefs.getBool(Store.viewGridKey) ?? false;
  final accent = prefs.getInt(Store.accentKey);
  runApp(AnimeTrackerApp(
    initialLocale: savedLocale,
    initialThemeMode: themeMode,
    initialViewGrid: viewGrid,
    initialAccent: accent,
  ));
}

class AnimeTrackerApp extends StatelessWidget {
  final String initialLocale;
  final String initialThemeMode;
  final bool initialViewGrid;
  final int? initialAccent;
  const AnimeTrackerApp({
    super.key,
    required this.initialLocale,
    this.initialThemeMode = 'dark',
    this.initialViewGrid = false,
    this.initialAccent,
  });

  @override
  Widget build(BuildContext context) {
    return L10nProvider(
      initialLocale: initialLocale,
      child: StoreProvider(
        initialThemeMode: initialThemeMode,
        initialViewGrid: initialViewGrid,
        initialAccent: initialAccent,
        child: Builder(
          builder: (ctx) {
            final dark = ctx.store.themeMode != 'light';
            return MaterialApp(
              title: 'Anime Tracker',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.build(
                dark ? Brightness.dark : Brightness.light,
                accent: ctx.store.accentColor == null
                    ? null
                    : Color(ctx.store.accentColor!),
              ),
              home: const RootScreen(),
            );
          },
        ),
      ),
    );
  }
}