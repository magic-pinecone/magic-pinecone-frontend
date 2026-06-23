import 'package:magic_pinecone/features/settings/domain/repository/settings_controls.dart';

class UpdateThemeUseCase {
  const UpdateThemeUseCase(this._themeController);

  final ThemePreferenceConfig _themeController;

  void toggleTheme() {
    _themeController.toggle();
  }

  void setDarkMode(bool enabled) {
    _themeController.setDarkMode(enabled);
  }
}
