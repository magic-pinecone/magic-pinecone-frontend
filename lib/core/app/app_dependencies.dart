import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/features/course_selection/data/course_schedule_repository.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:prototype/features/home/data/home_dashboard_repository.dart';
import 'package:prototype/features/home/presentation/view_models/home_view_model.dart';
import 'package:prototype/features/news/data/news_digest_repository.dart';
import 'package:prototype/features/news/data/scholarship_repository.dart';
import 'package:prototype/features/news/data/scholarship_service.dart';
import 'package:prototype/features/news/presentation/view_models/news_view_model.dart';
import 'package:prototype/features/portal/data/portal_authenticator.dart';
import 'package:prototype/features/portal/data/portal_shortcut_repository.dart';
import 'package:prototype/features/portal/presentation/view_models/portal_session_controller.dart';
import 'package:prototype/features/settings/data/settings_repository.dart';
import 'package:prototype/features/settings/presentation/view_models/settings_view_model.dart';

class AppDependencies {
  AppDependencies({
    AppThemeController? appThemeController,
    CourseScheduleRepository? courseScheduleRepository,
    HomeDashboardRepository? homeDashboardRepository,
    NewsDigestRepository? newsDigestRepository,
    PortalShortcutRepository? portalShortcutRepository,
    SettingsRepository? settingsRepository,
    ScholarshipService? scholarshipService,
    PortalAuthenticator? portalAuthenticator,
    ScholarshipRepository? scholarshipRepository,
  }) : this._internal(
         appThemeController: appThemeController ?? AppThemeController(),
         courseScheduleRepository:
             courseScheduleRepository ?? const StaticCourseScheduleRepository(),
         homeDashboardRepository:
             homeDashboardRepository ?? const StaticHomeDashboardRepository(),
         newsDigestRepository:
             newsDigestRepository ?? const StaticNewsDigestRepository(),
         portalShortcutRepository:
             portalShortcutRepository ?? const StaticPortalShortcutRepository(),
         settingsRepository:
             settingsRepository ?? const StaticSettingsRepository(),
         scholarshipService: scholarshipService ?? ScholarshipService(),
         portalAuthenticator: portalAuthenticator ?? PortalAuthenticator(),
         scholarshipRepository: scholarshipRepository,
       );

  AppDependencies._internal({
    required this.appThemeController,
    required this.courseScheduleRepository,
    required this.homeDashboardRepository,
    required this.newsDigestRepository,
    required this.portalShortcutRepository,
    required this.settingsRepository,
    required this.scholarshipService,
    required this.portalAuthenticator,
    ScholarshipRepository? scholarshipRepository,
  }) : scholarshipRepository =
           scholarshipRepository ??
           RemoteScholarshipRepository(service: scholarshipService);

  final AppThemeController appThemeController;
  final CourseScheduleRepository courseScheduleRepository;
  final HomeDashboardRepository homeDashboardRepository;
  final NewsDigestRepository newsDigestRepository;
  final PortalShortcutRepository portalShortcutRepository;
  final SettingsRepository settingsRepository;
  final ScholarshipService scholarshipService;
  final PortalAuthenticator portalAuthenticator;
  final ScholarshipRepository scholarshipRepository;

  HomeViewModel createHomeViewModel() {
    return HomeViewModel(repository: homeDashboardRepository);
  }

  SettingsViewModel createSettingsViewModel() {
    return SettingsViewModel(
      appThemeController: appThemeController,
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
    return CourseSelectionController(repository: courseScheduleRepository);
  }

  void dispose() {
    appThemeController.dispose();
  }
}
