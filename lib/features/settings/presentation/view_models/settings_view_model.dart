import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_backend_config.dart';
import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/features/settings/data/settings_repository.dart';
import 'package:prototype/features/settings/domain/models/settings_models.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required AppThemeController appThemeController,
    AppBackendConfigController? appBackendConfigController,
    required SettingsRepository repository,
  }) : _appThemeController = appThemeController,
       _appBackendConfigController = appBackendConfigController {
    _snapshot = repository.loadSettings();
    _appThemeController.addListener(_onThemeChanged);
    _appBackendConfigController?.addListener(_onBackendConfigChanged);
  }

  final AppThemeController _appThemeController;
  final AppBackendConfigController? _appBackendConfigController;
  late final SettingsSnapshot _snapshot;
  String? _backendBaseUrlError;
  bool _omitWeekendsOnTimetable = true;

  bool get omitWeekendsOnTimetable => _omitWeekendsOnTimetable;
  String get appName => _snapshot.appName;
  String get appVersion => _snapshot.appVersion;
  String get summary => _snapshot.summary;
  List<SettingsStatusItem> get statusItems => _snapshot.statusItems;
  ThemeMode get themeMode => _appThemeController.value;
  bool get isDarkMode => themeMode == ThemeMode.dark;
  String get backendBaseUrl => _appBackendConfigController?.baseUrl ?? '';
  String? get backendBaseUrlError => _backendBaseUrlError;

  void setOmitWeekendsOnTimetable(bool enabled) {
    _omitWeekendsOnTimetable = enabled;
    notifyListeners();
  }

  void toggleTheme() {
    _appThemeController.toggle();
  }

  void setDarkMode(bool enabled) {
    _appThemeController.setDarkMode(enabled);
  }

  void updateBackendBaseUrl(String value) {
    if (_appBackendConfigController == null) return;
    if (_appBackendConfigController.setBaseUrl(value)) {
      _backendBaseUrlError = null;
    } else {
      _backendBaseUrlError = '請輸入 http 或 https 開頭的網址';
    }
    notifyListeners();
  }

  void resetBackendBaseUrl() {
    _appBackendConfigController?.reset();
    _backendBaseUrlError = null;
    notifyListeners();
  }

  void _onThemeChanged() {
    notifyListeners();
  }

  void _onBackendConfigChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _appThemeController.removeListener(_onThemeChanged);
    _appBackendConfigController?.removeListener(_onBackendConfigChanged);
    super.dispose();
  }
}
