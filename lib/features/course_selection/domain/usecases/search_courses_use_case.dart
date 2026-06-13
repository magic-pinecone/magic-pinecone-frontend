import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_courses_use_case.g.dart';

class SearchCoursesUseCase {
  const SearchCoursesUseCase(this._repository);

  final CourseRepository _repository;

  Future<CourseSearchResult> execute({
    String keyword = '',
    String classNo = '',
    String serialNo = '',
    String departmentName = '',
    String collegeName = '',
    String instructor = '',
    String? courseType,
    List<int> credits = const [],
    bool? hasVacancy,
    List<String> classTimes = const [],
    int offset = 0,
    int limit = 50,
  }) {
    return _repository.searchCourses(
      keyword: keyword,
      classNo: classNo,
      serialNo: serialNo,
      departmentName: departmentName,
      collegeName: collegeName,
      instructor: instructor,
      courseType: courseType,
      credits: credits,
      hasVacancy: hasVacancy,
      classTimes: classTimes,
      offset: offset,
      limit: limit,
    );
  }
}

@riverpod
SearchCoursesUseCase searchCoursesUseCase(Ref ref) {
  return SearchCoursesUseCase(ref.watch(courseRepositoryProvider));
}
