import 'package:magic_pinecone/features/course_selection/data/data_sources/course_api_service.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/static_course_catalog_data_source.dart';
import 'package:magic_pinecone/features/course_selection/data/dtos/course_dto.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_repository.dart';

class BackendCourseRepository implements CourseRepository {
  BackendCourseRepository({required this.service});

  final CourseApiService service;

  @override
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? instructor,
    String? courseType,
    List<int>? credits,
    bool? hasVacancy,
    List<String>? classTimes,
    int offset = 0,
    int limit = 100,
  }) async {
    final result = await service.getCourse(
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

class StaticCourseCatalogRepository implements CourseRepository {
  StaticCourseCatalogRepository({required this.dataSource});

  final StaticCourseCatalogDataSource dataSource;
  CourseSearchResult? _cachedCatalog;

  @override
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? instructor,
    String? courseType,
    List<int>? credits,
    bool? hasVacancy,
    List<String>? classTimes,
    int offset = 0,
    int limit = 100,
  }) async {
    final catalog = await _loadCatalog();
    final filteredCourses = catalog.courses
        .where((course) {
          return _contains(course.title, keyword) &&
              _contains(course.classNo, classNo) &&
              _contains(course.serialNo, serialNo) &&
              _contains(course.departmentName, departmentName) &&
              _contains(course.collegeName, collegeName) &&
              _contains(course.teacherText, instructor) &&
              _matchesCourseType(course, courseType) &&
              _matchesCredits(course, credits) &&
              _matchesVacancy(course, hasVacancy) &&
              _matchesClassTimes(course, classTimes);
        })
        .toList(growable: false);

    final start = offset.clamp(0, filteredCourses.length);
    final end = (start + limit).clamp(start, filteredCourses.length);

    return CourseSearchResult(
      totalCount: filteredCourses.length,
      lastUpdated: catalog.lastUpdated,
      courses: filteredCourses.sublist(start, end),
    );
  }

  Future<CourseSearchResult> _loadCatalog() async {
    final cachedCatalog = _cachedCatalog;
    if (cachedCatalog != null) return cachedCatalog;

    final json = await dataSource.loadCatalogJson();
    final coursesJson = json['courses'] as List<dynamic>? ?? const [];
    final courses = coursesJson
        .map(
          (courseJson) => (courseJson as Map<String, dynamic>).toCourseItem(),
        )
        .toList(growable: false);

    final result = CourseSearchResult(
      totalCount: courses.length,
      lastUpdated: _parseDateTime(json['last_updated']),
      courses: courses,
    );
    _cachedCatalog = result;
    return result;
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  bool _contains(String? value, String? query) {
    final normalizedQuery = query?.trim().toLowerCase();
    if (normalizedQuery == null || normalizedQuery.isEmpty) return true;
    return value?.toLowerCase().contains(normalizedQuery) ?? false;
  }

  bool _matchesCourseType(CourseItem course, String? courseType) {
    final normalizedCourseType = courseType?.trim().toUpperCase();
    if (normalizedCourseType == null || normalizedCourseType.isEmpty) {
      return true;
    }
    return course.courseType?.trim().toUpperCase() == normalizedCourseType;
  }

  bool _matchesCredits(CourseItem course, List<int>? credits) {
    if (credits == null || credits.isEmpty) return true;
    return credits.contains(course.credit);
  }

  bool _matchesVacancy(CourseItem course, bool? hasVacancy) {
    if (hasVacancy == null) return true;

    final admitted = course.admitCount;
    final limit = course.limitCount;
    if (admitted == null || limit == null) return false;
    final hasAvailableVacancy = admitted < limit;
    return hasVacancy ? hasAvailableVacancy : !hasAvailableVacancy;
  }

  bool _matchesClassTimes(CourseItem course, List<String>? classTimes) {
    if (classTimes == null || classTimes.isEmpty) return true;
    return classTimes.every(course.classTimes.contains);
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

extension StaticCourseResponseJsonMapper on Map<String, dynamic> {
  CourseItem toCourseItem() {
    return CourseResponseDto.fromJson(this).toModel();
  }
}
