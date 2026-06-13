import 'package:flutter/material.dart';

// TODO: Migrate this controller from ValueNotifier to a modern Riverpod Notifier/AsyncNotifier
class AppThemeController extends ValueNotifier<ThemeMode> {
  AppThemeController() : super(ThemeMode.system);

  void toggle() {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setDarkMode(bool enabled) {
    value = enabled ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => value == ThemeMode.dark;
}

class AppTheme {
  AppTheme._();

  static final light = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 0.5),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    navigationBarTheme: const NavigationBarThemeData(elevation: 1),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 0.5),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    navigationBarTheme: const NavigationBarThemeData(elevation: 1),
  );
}
