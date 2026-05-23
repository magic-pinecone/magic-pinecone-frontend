import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/features/settings/data/settings_repository.dart';
import 'package:prototype/features/settings/models/settings_models.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required AppThemeController appThemeController,
    required SettingsRepository repository,
  }) : _appThemeController = appThemeController {
    _snapshot = repository.loadSettings();
    _appThemeController.addListener(_onThemeChanged);
  }

  final AppThemeController _appThemeController;
  late final SettingsSnapshot _snapshot;

  String get appName => _snapshot.appName;
  String get appVersion => _snapshot.appVersion;
  String get summary => _snapshot.summary;
  List<SettingsStatusItem> get statusItems => _snapshot.statusItems;
  ThemeMode get themeMode => _appThemeController.value;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme() {
    _appThemeController.toggle();
  }

  void _onThemeChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _appThemeController.removeListener(_onThemeChanged);
    super.dispose();
  }
}
