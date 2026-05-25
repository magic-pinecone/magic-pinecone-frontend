import 'package:dio/dio.dart';
import 'package:prototype/core/app/app_backend_config.dart';
import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/features/course_selection/data/course_api_service.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:prototype/features/home/data/home_dashboard_repository.dart';
import 'package:prototype/features/home/presentation/view_models/home_view_model.dart';
import 'package:prototype/features/news/data/news_digest_repository.dart';
import 'package:prototype/features/news/data/scholarship_api_service.dart';
import 'package:prototype/features/news/data/scholarship_repository.dart';
import 'package:prototype/features/news/presentation/view_models/news_view_model.dart';
import 'package:prototype/features/portal/data/portal_authenticator.dart';
import 'package:prototype/features/portal/data/portal_shortcut_repository.dart';
import 'package:prototype/features/portal/presentation/view_models/portal_session_controller.dart';
import 'package:prototype/features/settings/data/settings_repository.dart';
import 'package:prototype/features/settings/presentation/view_models/settings_view_model.dart';

class AppDependencies {
  AppDependencies({
    AppBackendConfigController? appBackendConfigController,
    AppThemeController? appThemeController,
    HomeDashboardRepository? homeDashboardRepository,
    NewsDigestRepository? newsDigestRepository,
    PortalShortcutRepository? portalShortcutRepository,
    SettingsRepository? settingsRepository,
    Dio? dio,
    CourseApiService? courseApiService,
    CourseRepository? courseRepository,
    ScholarshipApiService? scholarshipApiService,
    PortalAuthenticator? portalAuthenticator,
    ScholarshipRepository? scholarshipRepository,
  }) : this._internal(
         appBackendConfigController:
             appBackendConfigController ?? AppBackendConfigController(),
         appThemeController: appThemeController ?? AppThemeController(),
         homeDashboardRepository:
             homeDashboardRepository ?? const StaticHomeDashboardRepository(),
         newsDigestRepository:
             newsDigestRepository ?? const StaticNewsDigestRepository(),
         portalShortcutRepository:
             portalShortcutRepository ?? const StaticPortalShortcutRepository(),
         settingsRepository:
             settingsRepository ?? const StaticSettingsRepository(),
         dio: dio ?? Dio(),
         courseApiService: courseApiService,
         courseRepository: courseRepository,
         scholarshipApiService: scholarshipApiService,
         portalAuthenticator: portalAuthenticator ?? PortalAuthenticator(),
         scholarshipRepository: scholarshipRepository,
       );

  AppDependencies._internal({
    required this.appBackendConfigController,
    required this.appThemeController,
    required this.homeDashboardRepository,
    required this.newsDigestRepository,
    required this.portalShortcutRepository,
    required this.settingsRepository,
    required this.dio,
    CourseApiService? courseApiService,
    CourseRepository? courseRepository,
    ScholarshipApiService? scholarshipApiService,
    required this.portalAuthenticator,
    ScholarshipRepository? scholarshipRepository,
  }) {
    _syncBackendBaseUrl();
    appBackendConfigController.addListener(_syncBackendBaseUrl);

    final courseService = courseApiService ?? CourseApiService(dio);
    this.courseApiService = courseService;
    this.courseRepository =
        courseRepository ?? RemoteCourseRepository(service: courseService);

    final apiService = scholarshipApiService ?? ScholarshipApiService(dio);
    this.scholarshipApiService = apiService;
    this.scholarshipRepository =
        scholarshipRepository ??
        RemoteScholarshipRepository(service: apiService);
  }

  final AppBackendConfigController appBackendConfigController;
  final AppThemeController appThemeController;
  final HomeDashboardRepository homeDashboardRepository;
  final NewsDigestRepository newsDigestRepository;
  final PortalShortcutRepository portalShortcutRepository;
  final SettingsRepository settingsRepository;
  final Dio dio;
  late final CourseApiService courseApiService;
  late final CourseRepository courseRepository;
  late final ScholarshipApiService scholarshipApiService;
  final PortalAuthenticator portalAuthenticator;
  late final ScholarshipRepository scholarshipRepository;

  HomeViewModel createHomeViewModel() {
    return HomeViewModel(repository: homeDashboardRepository);
  }

  SettingsViewModel createSettingsViewModel() {
    return SettingsViewModel(
      appThemeController: appThemeController,
      appBackendConfigController: appBackendConfigController,
      repository: settingsRepository,
    );
  }

  NewsViewModel createNewsViewModel() {
    return NewsViewModel(
      repository: scholarshipRepository,
      digestRepository: newsDigestRepository,
    );
  }

  PortalSessionController createPortalSessionController() {
    return PortalSessionController(
      authenticator: portalAuthenticator,
      shortcutRepository: portalShortcutRepository,
    );
  }

  CourseSelectionController createCourseSelectionController() {
    return CourseSelectionController(repository: courseRepository);
  }

  void dispose() {
    appBackendConfigController.removeListener(_syncBackendBaseUrl);
    appBackendConfigController.dispose();
    appThemeController.dispose();
  }

  void _syncBackendBaseUrl() {
    dio.options.baseUrl = appBackendConfigController.baseUrl;
  }
}
