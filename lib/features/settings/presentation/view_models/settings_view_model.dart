import 'package:flutter/material.dart';
import 'package:magic_pinecone/core/app/app_backend_config.dart';
import 'package:magic_pinecone/core/app/app_theme.dart';
import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_repository.dart';

// TODO: Migrate this controller from ChangeNotifier to a modern Riverpod Notifier/AsyncNotifier
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this.appThemeController,
    this.appBackendConfigController,
    required SettingsRepository repository,
  }) {
    _snapshot = repository.loadSettings();
    appThemeController.addListener(_onThemeChanged);
    appBackendConfigController?.addListener(_onBackendConfigChanged);
  }

  final AppThemeController appThemeController;
  final AppBackendConfigController? appBackendConfigController;
  late final SettingsSnapshot _snapshot;
  String? _backendBaseUrlError;
  bool _omitWeekendsOnTimetable = true;

  bool get omitWeekendsOnTimetable => _omitWeekendsOnTimetable;
  String get appName => _snapshot.appName;
  String get appVersion => _snapshot.appVersion;
  String get summary => _snapshot.summary;
  List<SettingsStatusItem> get statusItems => _snapshot.statusItems;
  ThemeMode get themeMode => appThemeController.value;
  bool get isDarkMode => themeMode == ThemeMode.dark;
  String get backendBaseUrl => appBackendConfigController?.baseUrl ?? '';
  String? get backendBaseUrlError => _backendBaseUrlError;

  void setOmitWeekendsOnTimetable(bool enabled) {
    _omitWeekendsOnTimetable = enabled;
    notifyListeners();
  }

  void toggleTheme() {
    appThemeController.toggle();
  }

  void setDarkMode(bool enabled) {
    appThemeController.setDarkMode(enabled);
  }

  void updateBackendBaseUrl(String value) {
    final controller = appBackendConfigController;
    if (controller == null) return;
    if (controller.setBaseUrl(value)) {
      _backendBaseUrlError = null;
    } else {
      _backendBaseUrlError = '請輸入 http 或 https 開頭的網址';
    }
    notifyListeners();
  }

  void resetBackendBaseUrl() {
    appBackendConfigController?.reset();
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
    appThemeController.removeListener(_onThemeChanged);
    appBackendConfigController?.removeListener(_onBackendConfigChanged);
    super.dispose();
  }
}
