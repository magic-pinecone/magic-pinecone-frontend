import 'package:dio/dio.dart';
import 'package:magic_pinecone/core/app/app_backend_config.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_api_service.dart';
import 'package:magic_pinecone/features/course_selection/data/repositories/course_repository_impl.dart';
import 'package:magic_pinecone/features/course_selection/data/repositories/course_supplemental_detail_repository_impl.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_repository.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_supplemental_detail_repository.dart';
import 'package:magic_pinecone/features/home/data/repositories/home_dashboard_repository_impl.dart';
import 'package:magic_pinecone/features/home/domain/repository/home_dashboard_repository.dart';

import 'package:magic_pinecone/features/news/data/data_sources/scholarship_api_service.dart';
import 'package:magic_pinecone/features/news/data/repositories/news_digest_repository_impl.dart';
import 'package:magic_pinecone/features/news/data/repositories/scholarship_repository_impl.dart';
import 'package:magic_pinecone/features/news/domain/repository/news_digest_repository.dart';
import 'package:magic_pinecone/features/news/domain/repository/scholarship_repository.dart';

import 'package:magic_pinecone/features/portal/data/data_sources/portal_authenticator.dart';
import 'package:magic_pinecone/features/portal/data/repositories/portal_shortcut_repository_impl.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_shortcut_repository.dart';
import 'package:magic_pinecone/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:magic_pinecone/core/app/app_backend_config.dart'
    show appBackendConfigControllerProvider;
export 'package:magic_pinecone/core/app/app_theme.dart'
    show appThemeControllerProvider;

part 'app_providers.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();
  final baseUrl = ref.read(appBackendConfigControllerProvider);
  dio.options.baseUrl = baseUrl;

  ref.listen<String>(appBackendConfigControllerProvider, (previous, next) {
    dio.options.baseUrl = next;
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
