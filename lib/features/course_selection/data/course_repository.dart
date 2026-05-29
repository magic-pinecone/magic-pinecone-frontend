import 'package:prototype/features/course_selection/data/course_api_service.dart';
import 'package:prototype/features/course_selection/data/dtos/course_dto.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';

abstract class CourseRepository {
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? courseType,
    List<int>? credits,
    bool? hasVacancy,
    List<String>? classTimes,
    int offset = 0,
    int limit = 100,
  });
}

class RemoteCourseRepository implements CourseRepository {
  RemoteCourseRepository({required CourseApiService service})
    : _service = service;

  final CourseApiService _service;

  @override
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? courseType,
    List<int>? credits,
    bool? hasVacancy,
    List<String>? classTimes,
    int offset = 0,
    int limit = 100,
  }) async {
    final result = await _service.getCourse(
      keyword: _normalize(keyword),
      classNo: _normalize(classNo),
      serialNo: _normalize(serialNo),
      departmentName: _normalize(departmentName),
      collegeName: _normalize(collegeName),
      courseType: _normalize(courseType),
      credits: _normalizeList(credits),
      hasVacancy: hasVacancy,
      classTimes: _normalizeList(classTimes),
      offset: offset,
      limit: limit,
    );
    return result.toModel();
  }

  String? _normalize(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  List<T>? _normalizeList<T>(List<T>? values) {
    if (values == null || values.isEmpty) return null;
    return values;
  }
}

extension CourseResultDtoMapper on CourseResultDto {
  CourseSearchResult toModel() {
    return CourseSearchResult(
      totalCount: totalCount,
      lastUpdated: lastUpdated,
      courses: courses
          .map((course) => course.toModel())
          .toList(growable: false),
    );
  }
}

extension CourseResponseDtoMapper on CourseResponseDto {
  CourseItem toModel() {
    return CourseItem(
      serialNo: serialNo,
      classNo: classNo,
      title: title,
      credit: credit,
      passwordCard: passwordCard,
      teachers: teachers,
      classTimes: classTimes,
      limitCount: limitCnt,
      admitCount: admitCnt,
      waitCount: waitCnt,
      collegeName: collegeName,
      departmentName: departmentName,
      courseType: courseType,
    );
  }
}
