import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/app/app_backend_config.dart';
import 'package:prototype/core/app/app_dependencies.dart';
import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:prototype/features/home/data/home_dashboard_repository.dart';
import 'package:prototype/features/home/presentation/view_models/home_view_model.dart';
import 'package:prototype/features/news/data/news_digest_repository.dart';
import 'package:prototype/features/news/presentation/view_models/news_view_model.dart';
import 'package:prototype/features/portal/data/portal_shortcut_repository.dart';
import 'package:prototype/features/portal/presentation/view_models/portal_session_controller.dart';
import 'package:prototype/features/settings/data/settings_repository.dart';
import 'package:prototype/features/settings/presentation/view_models/settings_view_model.dart';

void main() {
  test('AppDependencies provides a theme controller by default', () {
    final dependencies = AppDependencies();

    expect(dependencies.appThemeController, isA<AppThemeController>());
    expect(dependencies.appThemeController.value, ThemeMode.system);
    expect(
      dependencies.appBackendConfigController.baseUrl,
      defaultBackendBaseUrl,
    );
    expect(dependencies.dio.options.baseUrl, defaultBackendBaseUrl);
  });

  test('AppDependencies syncs backend base URL to Dio', () {
    final dependencies = AppDependencies();

    dependencies.appBackendConfigController.setBaseUrl('http://127.0.0.1:8000');

    expect(dependencies.dio.options.baseUrl, 'http://127.0.0.1:8000');

    dependencies.dispose();
  });

  test(
    'AppDependencies creates page-scoped controllers from shared services',
    () {
      final dependencies = AppDependencies();

      expect(dependencies.createHomeViewModel(), isA<HomeViewModel>());
      expect(dependencies.createNewsViewModel(), isA<NewsViewModel>());
      expect(dependencies.createSettingsViewModel(), isA<SettingsViewModel>());
      expect(
        dependencies.createPortalSessionController(),
        isA<PortalSessionController>(),
      );
      expect(
        dependencies.createCourseSelectionController(),
        isA<CourseSelectionController>(),
      );
      expect(dependencies.courseRepository, isA<CourseRepository>());
      expect(
        dependencies.homeDashboardRepository,
        isA<HomeDashboardRepository>(),
      );
      expect(dependencies.newsDigestRepository, isA<NewsDigestRepository>());
      expect(
        dependencies.portalShortcutRepository,
        isA<PortalShortcutRepository>(),
      );
      expect(dependencies.settingsRepository, isA<SettingsRepository>());
    },
  );
}
