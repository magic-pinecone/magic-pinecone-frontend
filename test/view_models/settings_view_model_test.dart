import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/features/settings/data/settings_repository.dart';
import 'package:prototype/features/settings/models/settings_models.dart';
import 'package:prototype/features/settings/presentation/view_models/settings_view_model.dart';

void main() {
  test('SettingsViewModel exposes repository data and theme state', () {
    final themeController = AppThemeController();
    final viewModel = SettingsViewModel(
      appThemeController: themeController,
      repository: const FakeSettingsRepository(),
    );

    expect(viewModel.appName, 'Magic Pinecone');
    expect(viewModel.appVersion, '0.1.0+1');
    expect(viewModel.statusItems, hasLength(1));
    expect(viewModel.isDarkMode, isFalse);

    themeController.value = ThemeMode.dark;

    expect(viewModel.isDarkMode, isTrue);
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
