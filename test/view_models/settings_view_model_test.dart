import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/core/app/app_backend_config.dart';
import 'package:magic_pinecone/core/app/app_theme.dart';
import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_repository.dart';
import 'package:magic_pinecone/features/settings/presentation/view_models/settings_view_model.dart';

void main() {
  test('SettingsViewModel exposes repository data and theme state', () {
    final themeController = AppThemeController();
    final backendConfigController = AppBackendConfigController();
    final viewModel = SettingsViewModel(
      appThemeController: themeController,
      appBackendConfigController: backendConfigController,
      repository: const FakeSettingsRepository(),
    );

    expect(viewModel.appName, 'Magic Pinecone');
    expect(viewModel.appVersion, '0.1.0+1');
    expect(viewModel.statusItems, hasLength(1));
    expect(viewModel.isDarkMode, isFalse);

    themeController.value = ThemeMode.dark;

    expect(viewModel.isDarkMode, isTrue);

    viewModel.setDarkMode(false);

    expect(themeController.value, ThemeMode.light);
    expect(viewModel.isDarkMode, isFalse);

    viewModel.updateBackendBaseUrl('http://127.0.0.1:8000/');

    expect(viewModel.backendBaseUrl, 'http://127.0.0.1:8000');
    expect(viewModel.backendBaseUrlError, isNull);

    viewModel.updateBackendBaseUrl('localhost:8000');

    expect(viewModel.backendBaseUrl, 'http://127.0.0.1:8000');
    expect(viewModel.backendBaseUrlError, isNotNull);
  });
}

class FakeSettingsRepository implements SettingsRepository {
  const FakeSettingsRepository();

  @override
  SettingsSnapshot loadSettings() {
    return const SettingsSnapshot(
      appName: 'Magic Pinecone',
      appVersion: '0.1.0+1',
      summary: '目前版本聚焦在行動端展示。',
      statusItems: [SettingsStatusItem(label: '首頁與快速功能已串成實際流程')],
    );
  }
}
