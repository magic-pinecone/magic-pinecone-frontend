import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/app/app_backend_config.dart';
import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/features/settings/data/settings_repository.dart';
import 'package:prototype/features/settings/domain/models/settings_models.dart';
import 'package:prototype/features/settings/presentation/settings_page.dart';
import 'package:prototype/features/settings/presentation/view_models/settings_view_model.dart';

void main() {
  testWidgets('SettingsPage reflects system dark mode on first render', (
    tester,
  ) async {
    final themeController = AppThemeController();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeController.value,
        home: SettingsPage(
          viewModel: SettingsViewModel(
            appThemeController: themeController,
            appBackendConfigController: AppBackendConfigController(),
            repository: const FakeSettingsRepository(),
          ),
        ),
      ),
    );

    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));

    expect(tile.value, isTrue);
    expect(find.text('開啟'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(themeController.value, ThemeMode.light);
  });

  testWidgets('SettingsPage renders theme and project info sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          viewModel: SettingsViewModel(
            appThemeController: AppThemeController(),
            appBackendConfigController: AppBackendConfigController(),
            repository: const FakeSettingsRepository(),
          ),
        ),
      ),
    );

    expect(find.text('顯示與偏好'), findsOneWidget);
    expect(find.text('深色模式'), findsOneWidget);
    expect(find.text('後端服務'), findsOneWidget);
    expect(find.text('Backend URL'), findsOneWidget);
    expect(find.text('專案資訊'), findsOneWidget);
    expect(find.text('Magic Pinecone'), findsOneWidget);
    expect(find.text('首頁與快速功能已串成實際流程'), findsOneWidget);
  });

  testWidgets('SettingsPage updates backend URL from form', (tester) async {
    final backendConfigController = AppBackendConfigController();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          viewModel: SettingsViewModel(
            appThemeController: AppThemeController(),
            appBackendConfigController: backendConfigController,
            repository: const FakeSettingsRepository(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'http://127.0.0.1:8000');
    await tester.tap(find.text('套用'));
    await tester.pump();

    expect(backendConfigController.baseUrl, 'http://127.0.0.1:8000');

    await tester.enterText(find.byType(TextField), 'localhost:8000');
    await tester.tap(find.text('套用'));
    await tester.pump();

    expect(find.text('請輸入 http 或 https 開頭的網址'), findsOneWidget);
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
