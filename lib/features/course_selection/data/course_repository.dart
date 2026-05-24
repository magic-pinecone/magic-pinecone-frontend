import 'package:prototype/features/course_selection/data/course_api_service.dart';
import 'package:prototype/features/course_selection/data/dtos/course_dto.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';

abstract class CourseRepository {
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentId,
    String? collegeId,
    String? courseType,
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
    String? departmentId,
    String? collegeId,
    String? courseType,
    int offset = 0,
    int limit = 100,
  }) async {
    final result = await _service.getCourse(
      keyword: _normalize(keyword),
      classNo: _normalize(classNo),
      serialNo: _normalize(serialNo),
      departmentId: _normalize(departmentId),
      collegeId: _normalize(collegeId),
      courseType: _normalize(courseType),
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
      collegeId: collegeId,
      departmentId: departmentId,
      courseType: courseType,
    );
  }
}
