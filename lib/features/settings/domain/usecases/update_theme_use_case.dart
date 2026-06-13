import 'package:magic_pinecone/core/app/app_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_theme_use_case.g.dart';

class UpdateThemeUseCase {
  const UpdateThemeUseCase(this._themeController);

  final AppThemeController _themeController;

  void toggleTheme() {
    _themeController.toggle();
  }

  void setDarkMode(bool enabled) {
    _themeController.setDarkMode(enabled);
  }
}

@riverpod
UpdateThemeUseCase updateThemeUseCase(Ref ref) {
  return UpdateThemeUseCase(ref.watch(appThemeControllerProvider.notifier));
}
