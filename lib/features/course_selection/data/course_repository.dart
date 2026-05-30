import 'dart:convert';

import 'package:dio/dio.dart';
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

const staticRemoteCoursesUrl =
    'https://raw.githubusercontent.com/magic-pinecone/magic-pinecone-backend-light/115-1/courses.json';

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

class StaticRemoteCourseRepository implements CourseRepository {
  StaticRemoteCourseRepository({
    required Dio dio,
    this.coursesUrl = staticRemoteCoursesUrl,
  }) : _dio = dio;

  final Dio _dio;
  final String coursesUrl;
  CourseSearchResult? _cachedCatalog;

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
    final catalog = await _loadCatalog();
    final filteredCourses = catalog.courses
        .where((course) {
          return _contains(course.title, keyword) &&
              _contains(course.classNo, classNo) &&
              _contains(course.serialNo, serialNo) &&
              _contains(course.departmentName, departmentName) &&
              _contains(course.collegeName, collegeName) &&
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

    final response = await _dio.getUri<Object>(Uri.parse(coursesUrl));
    final json = _decodeJsonObject(response.data);
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

  Map<String, dynamic> _decodeJsonObject(Object? data) {
    final decoded = switch (data) {
      final Map<String, dynamic> value => value,
      final Map<Object?, Object?> value => Map<String, dynamic>.from(value),
      final String value => jsonDecode(value) as Map<String, dynamic>,
      _ => throw FormatException('Unexpected courses payload: $data'),
    };
    return decoded;
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
