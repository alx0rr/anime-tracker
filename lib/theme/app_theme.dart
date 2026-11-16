import 'package:flutter/material.dart';

class AppPalette {
  final Brightness brightness;
  final Color bg, surface, surfaceHigh, outline;
  final Color text, textDim, textFaint;
  final Color accent, onAccent, secondary, info;
  final Color danger, success;

  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.outline,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.accent,
    required this.onAccent,
    required this.secondary,
    required this.info,
    required this.danger,
    required this.success,
  });

  static const dark = AppPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF14120F),
    surface: Color(0xFF1E1B16),
    surfaceHigh: Color(0xFF29251E),
    outline: Color(0xFF3A3429),
    text: Color(0xFFF0E7D6),
    textDim: Color(0xFFB5AB97),
    textFaint: Color(0xFF7D7565),
    accent: Color(0xFFE3A24F),
    onAccent: Color(0xFF1C1408),
    secondary: Color(0xFFC9604A),
    info: Color(0xFF6F9FAE),
    danger: Color(0xFFD8604E),
    success: Color(0xFF8FA86B),
  );

  static const light = AppPalette(
    brightness: Brightness.light,
    bg: Color(0xFFF6F1E7),
    surface: Color(0xFFFFFCF6),
    surfaceHigh: Color(0xFFEFE8D9),
    outline: Color(0xFFDDD3BF),
    text: Color(0xFF2A2318),
    textDim: Color(0xFF5E5543),
    textFaint: Color(0xFF8F8573),
    accent: Color(0xFFC27512),
    onAccent: Color(0xFFFFF8EA),
    secondary: Color(0xFFB5503B),
    info: Color(0xFF4F7F8E),
    danger: Color(0xFFC0463A),
    success: Color(0xFF6B8A3F),
  );
}

class AppColors {
  AppColors._();

  static AppPalette _p = AppPalette.dark;

  static Color? _customAccent;

  static void apply(Brightness b, {Color? accent}) {
    _p = b == Brightness.dark ? AppPalette.dark : AppPalette.light;
    _customAccent = accent;
  }

  static Color get defaultAccent => _p.accent;

  static bool get isDark => _p.brightness == Brightness.dark;

  static Color get bg => _p.bg;
  static Color get surface => _p.surface;
  static Color get surfaceHigh => _p.surfaceHigh;
  static Color get outline => _p.outline;

  static Color get text => _p.text;
  static Color get textDim => _p.textDim;
  static Color get textFaint => _p.textFaint;

  static Color get accent => _customAccent ?? _p.accent;
  static Color get onAccent =>
      _customAccent == null ? _p.onAccent : on(_customAccent!);
  static Color get secondary => _p.secondary;
  static Color get info => _p.info;

  static Color get danger => _p.danger;
  static Color get success => _p.success;

  static List<Color> get logoGradient => [accent, secondary];

  static const List<int> tagPalette = [
    0xFFE3A24F,
    0xFFD9822B,
    0xFFC9604A,
    0xFFB8434F,
    0xFFD17A8A,
    0xFFA66A8F,
    0xFF8672B5,
    0xFF6F86B8,
    0xFF5F9AA8,
    0xFF4FA38F,
    0xFF86A55B,
    0xFFB5B35C,
    0xFFD6B36A,
    0xFFA8805A,
    0xFF8C8577,
    0xFFE0C9A6,
  ];

  static Color on(Color c) =>
      ThemeData.estimateBrightnessForColor(c) == Brightness.light
          ? const Color(0xFF1C1408)
          : const Color(0xFFF0E7D6);
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() => build(Brightness.dark);
  static ThemeData light() => build(Brightness.light);

  static ThemeData build(Brightness brightness, {Color? accent}) {
    AppColors.apply(brightness, accent: accent);
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.secondary,
      onSecondary: isDark ? AppColors.text : Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textDim,
      secondaryContainer: AppColors.surfaceHigh,
      onSecondaryContainer: AppColors.text,
      error: AppColors.danger,
      onError: Colors.white,
      outline: AppColors.outline,
      surfaceTint: Colors.transparent,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHigh,
    );

    final baseText = ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        );

    RoundedRectangleBorder rr(double r) =>
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.surface,
      textTheme: baseText,
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: SoftPageTransitionsBuilder(),
        TargetPlatform.iOS: SoftPageTransitionsBuilder(),
        TargetPlatform.windows: SoftPageTransitionsBuilder(),
        TargetPlatform.macOS: SoftPageTransitionsBuilder(),
        TargetPlatform.linux: SoftPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.textDim),
      dividerTheme: DividerThemeData(
        color: AppColors.outline,
        space: 1,
        thickness: 1,
      ),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: AppColors.accent),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionHandleColor: AppColors.accent,
        selectionColor: AppColors.accent.withOpacity(0.3),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.accent.withOpacity(0.16),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            color: sel ? AppColors.accent : AppColors.textFaint,
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? AppColors.accent : AppColors.textFaint,
            size: 24,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        elevation: 3,
        highlightElevation: 6,
        shape: rr(18),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: TextStyle(color: AppColors.text),
        shape: rr(12),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: AppColors.text, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.outline,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: rr(14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDim,
          side: BorderSide(color: AppColors.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: rr(14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      ),
    );
  }
}

class SoftPageTransitionsBuilder extends PageTransitionsBuilder {
  const SoftPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
