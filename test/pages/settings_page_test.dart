import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/features/settings/data/settings_repository.dart';
import 'package:prototype/features/settings/models/settings_models.dart';
import 'package:prototype/features/settings/presentation/settings_page.dart';
import 'package:prototype/features/settings/presentation/view_models/settings_view_model.dart';

void main() {
  testWidgets('SettingsPage renders theme and project info sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          viewModel: SettingsViewModel(
            appThemeController: AppThemeController(),
            repository: const FakeSettingsRepository(),
          ),
        ),
      ),
    );

    expect(find.text('顯示與偏好'), findsOneWidget);
    expect(find.text('深色模式'), findsOneWidget);
    expect(find.text('專案資訊'), findsOneWidget);
    expect(find.text('Magic Pinecone'), findsOneWidget);
    expect(find.text('首頁與快速功能已串成實際流程'), findsOneWidget);
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
