import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_api_service.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/static_course_catalog_data_source.dart';
import 'package:magic_pinecone/features/course_selection/data/repositories/course_repository_impl.dart';
import 'package:magic_pinecone/features/course_selection/data/repositories/course_supplemental_detail_repository_impl.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_repository.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_supplemental_detail_repository.dart';
import 'package:magic_pinecone/features/course_selection/domain/usecases/find_courses_by_serial_nos_use_case.dart';
import 'package:magic_pinecone/features/course_selection/domain/usecases/search_courses_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_selection_providers.g.dart';

@riverpod
CourseApiService courseApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CourseApiService(dio);
}

@riverpod
StaticCourseCatalogDataSource staticCourseCatalogDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return StaticCourseCatalogDataSource(dio: dio);
}

@riverpod
CourseRepository backendCourseRepository(Ref ref) {
  final service = ref.watch(courseApiServiceProvider);
  return BackendCourseRepository(service: service);
}

@riverpod
CourseRepository courseRepository(Ref ref) {
  final dataSource = ref.watch(staticCourseCatalogDataSourceProvider);
  return StaticCourseCatalogRepository(dataSource: dataSource);
}

@riverpod
CourseSupplementalDetailRepository courseSupplementalDetailRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return StaticRemoteCourseSupplementalDetailRepository(dio: dio);
}

@riverpod
SearchCoursesUseCase searchCoursesUseCase(Ref ref) {
  return SearchCoursesUseCase(ref.watch(courseRepositoryProvider));
}

@riverpod
FindCoursesBySerialNosUseCase findCoursesBySerialNosUseCase(Ref ref) {
  return FindCoursesBySerialNosUseCase(ref.watch(courseRepositoryProvider));
}
