import 'package:magic_pinecone/core/app/app_backend_config.dart';
import 'package:magic_pinecone/core/app/app_theme.dart';
import 'package:magic_pinecone/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_controls.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_repository.dart';
import 'package:magic_pinecone/features/settings/domain/usecases/load_settings_use_case.dart';
import 'package:magic_pinecone/features/settings/domain/usecases/update_backend_url_use_case.dart';
import 'package:magic_pinecone/features/settings/domain/usecases/update_theme_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return const StaticSettingsRepository();
}

@riverpod
LoadSettingsUseCase loadSettingsUseCase(Ref ref) {
  return LoadSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
UpdateBackendUrlUseCase updateBackendUrlUseCase(Ref ref) {
  return UpdateBackendUrlUseCase(
    _BackendUrlConfigAdapter(
      ref.watch(appBackendConfigControllerProvider.notifier),
    ),
  );
}

@riverpod
UpdateThemeUseCase updateThemeUseCase(Ref ref) {
  return UpdateThemeUseCase(
    _ThemePreferenceConfigAdapter(
      ref.watch(appThemeControllerProvider.notifier),
    ),
  );
}

class _BackendUrlConfigAdapter implements BackendUrlConfig {
  const _BackendUrlConfigAdapter(this._controller);

  final AppBackendConfigController _controller;

  @override
  bool setBaseUrl(String url) {
    return _controller.setBaseUrl(url);
  }

  @override
  void reset() {
    _controller.reset();
  }
}

class _ThemePreferenceConfigAdapter implements ThemePreferenceConfig {
  const _ThemePreferenceConfigAdapter(this._controller);

  final AppThemeController _controller;

  @override
  void setDarkMode(bool enabled) {
    _controller.setDarkMode(enabled);
  }

  @override
  void toggle() {
    _controller.toggle();
  }
}
