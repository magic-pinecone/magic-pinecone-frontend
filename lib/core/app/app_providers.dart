import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:magic_pinecone/core/app/app_backend_config.dart';
import 'package:magic_pinecone/core/app/app_theme.dart';
import 'package:magic_pinecone/features/course_selection/data/course_api_service.dart';
import 'package:magic_pinecone/features/course_selection/data/course_repository.dart';
import 'package:magic_pinecone/features/course_selection/data/course_supplemental_detail_catalog.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:magic_pinecone/features/home/data/home_dashboard_repository.dart';
import 'package:magic_pinecone/features/home/presentation/view_models/home_view_model.dart';
import 'package:magic_pinecone/features/news/data/news_digest_repository.dart';
import 'package:magic_pinecone/features/news/data/scholarship_api_service.dart';
import 'package:magic_pinecone/features/news/data/scholarship_repository.dart';
import 'package:magic_pinecone/features/news/presentation/view_models/news_view_model.dart';
import 'package:magic_pinecone/features/portal/data/portal_authenticator.dart';
import 'package:magic_pinecone/features/portal/data/portal_shortcut_repository.dart';
import 'package:magic_pinecone/features/portal/presentation/view_models/portal_session_controller.dart';
import 'package:magic_pinecone/features/settings/data/settings_repository.dart';
import 'package:magic_pinecone/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

// TODO: Migrate legacy ChangeNotifierProvider to modern Riverpod Notifier/AsyncNotifier
final appThemeControllerProvider = ChangeNotifierProvider<AppThemeController>((
  ref,
) {
  return AppThemeController();
});

// TODO: Migrate legacy ChangeNotifierProvider to modern Riverpod Notifier/AsyncNotifier
final appBackendConfigControllerProvider =
    ChangeNotifierProvider<AppBackendConfigController>((ref) {
      return AppBackendConfigController();
    });

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();
  final config = ref.read(appBackendConfigControllerProvider);
  dio.options.baseUrl = config.baseUrl;

  ref.listen<AppBackendConfigController>(appBackendConfigControllerProvider, (
    previous,
    next,
  ) {
    dio.options.baseUrl = next.baseUrl;
  });
  return dio;
}

@riverpod
CourseApiService courseApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CourseApiService(dio);
}

@riverpod
CourseRepository courseRepository(Ref ref) {
  final service = ref.watch(courseApiServiceProvider);
  return RemoteCourseRepository(service: service);
}

@riverpod
CourseSupplementalDetailRepository courseSupplementalDetailRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return StaticRemoteCourseSupplementalDetailRepository(dio: dio);
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return const StaticSettingsRepository();
}

@riverpod
HomeDashboardRepository homeDashboardRepository(Ref ref) {
  return const StaticHomeDashboardRepository();
}

@riverpod
NewsDigestRepository newsDigestRepository(Ref ref) {
  return const StaticNewsDigestRepository();
}

@riverpod
PortalShortcutRepository portalShortcutRepository(Ref ref) {
  return const StaticPortalShortcutRepository();
}

@riverpod
ScholarshipApiService scholarshipApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ScholarshipApiService(dio);
}

@riverpod
ScholarshipRepository scholarshipRepository(Ref ref) {
  final service = ref.watch(scholarshipApiServiceProvider);
  return RemoteScholarshipRepository(service: service);
}

@riverpod
PortalAuthenticator portalAuthenticator(Ref ref) {
  return PortalAuthenticator();
}

// view models: ChangeNotifiers
// TODO: Migrate legacy ChangeNotifierProvider to modern Riverpod Notifier/AsyncNotifier
final courseSelectionControllerProvider =
    ChangeNotifierProvider.autoDispose<CourseSelectionController>((ref) {
      final repository = ref.watch(courseRepositoryProvider);
      return CourseSelectionController(repository: repository);
    });

// TODO: Migrate legacy ChangeNotifierProvider to modern Riverpod Notifier/AsyncNotifier
final settingsViewModelProvider =
    ChangeNotifierProvider.autoDispose<SettingsViewModel>((ref) {
      final appThemeController = ref.watch(appThemeControllerProvider);
      final appBackendConfigController = ref.watch(
        appBackendConfigControllerProvider,
      );
      final repository = ref.watch(settingsRepositoryProvider);
      return SettingsViewModel(
        appThemeController: appThemeController,
        appBackendConfigController: appBackendConfigController,
        repository: repository,
      );
    });

// TODO: Migrate legacy ChangeNotifierProvider to modern Riverpod Notifier/AsyncNotifier
final homeViewModelProvider = ChangeNotifierProvider.autoDispose<HomeViewModel>(
  (ref) {
    final repository = ref.watch(homeDashboardRepositoryProvider);
    return HomeViewModel(repository: repository);
  },
);

// TODO: Migrate legacy ChangeNotifierProvider to modern Riverpod Notifier/AsyncNotifier
final newsViewModelProvider = ChangeNotifierProvider.autoDispose<NewsViewModel>(
  (ref) {
    final repository = ref.watch(scholarshipRepositoryProvider);
    final digestRepository = ref.watch(newsDigestRepositoryProvider);
    return NewsViewModel(
      repository: repository,
      digestRepository: digestRepository,
    );
  },
);

// TODO: Migrate legacy ChangeNotifierProvider to modern Riverpod Notifier/AsyncNotifier
final portalSessionControllerProvider =
    ChangeNotifierProvider.autoDispose<PortalSessionController>((ref) {
      final authenticator = ref.watch(portalAuthenticatorProvider);
      final shortcutRepository = ref.watch(portalShortcutRepositoryProvider);
      return PortalSessionController(
        authenticator: authenticator,
        shortcutRepository: shortcutRepository,
      );
    });
