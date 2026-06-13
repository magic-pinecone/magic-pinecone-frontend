import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'find_courses_by_serial_nos_use_case.g.dart';

class FindCoursesBySerialNosUseCase {
  const FindCoursesBySerialNosUseCase(this._repository);

  final CourseRepository _repository;

  Future<List<CourseItem>> execute({
    required Iterable<String> serialNos,
    List<CourseItem> cachedCourses = const [],
  }) async {
    final uniqueSerialNos = {
      for (final serialNo in serialNos)
        if (serialNo.trim().isNotEmpty) serialNo.trim(),
    };
    final coursesBySerialNo = {
      for (final course in cachedCourses) course.serialNo: course,
    };

    for (final serialNo in uniqueSerialNos) {
      if (coursesBySerialNo.containsKey(serialNo)) continue;

      final result = await _repository.searchCourses(
        serialNo: serialNo,
        limit: 10,
      );
      for (final course in result.courses) {
        if (course.serialNo == serialNo) {
          coursesBySerialNo[serialNo] = course;
          break;
        }
      }
    }

    return [
      for (final serialNo in uniqueSerialNos)
        if (coursesBySerialNo[serialNo] != null) coursesBySerialNo[serialNo]!,
    ];
  }
}

@riverpod
FindCoursesBySerialNosUseCase findCoursesBySerialNosUseCase(Ref ref) {
  return FindCoursesBySerialNosUseCase(ref.watch(courseRepositoryProvider));
}
