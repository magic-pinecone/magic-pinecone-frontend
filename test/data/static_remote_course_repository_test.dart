import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/course_selection/data/course_repository.dart';
import 'package:magic_pinecone/features/course_selection/data/course_supplemental_detail_catalog.dart';

void main() {
  test('static course URLs use current semester branch', () {
    expect(staticRemoteCoursesUrl, contains('/magic-pinecone-lite/'));
    expect(staticRemoteCoursesUrl, contains('/115-1/courses.json'));
    expect(staticRemoteCourseDetailsBaseUrl, contains('/magic-pinecone-lite/'));
    expect(staticRemoteCourseDetailsBaseUrl, contains('/115-1/detail'));
  });

  test('StaticRemoteCourseRepository filters and paginates courses', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeJsonAdapter({
        staticRemoteCoursesUrl: {
          'last_updated': '2026-05-30T01:54:41.657634+00:00',
          'courses': [
            {
              'serial_no': '00001',
              'class_no': 'LN0001',
              'title': '日文（一）A',
              'credit': 3.0,
              'teachers': ['王中成'],
              'class_times': ['1-1', '1-2'],
              'limit_cnt': 50,
              'admit_cnt': 49,
              'college_name': '中心、處室',
              'department_name': '語言中心',
              'course_type': 'ELECTIVE',
            },
            {
              'serial_no': '00002',
              'class_no': 'CS1001',
              'title': '程式設計',
              'credit': 3.0,
              'teachers': ['王小明'],
              'class_times': ['2-1', '2-2'],
              'limit_cnt': 60,
              'admit_cnt': 60,
              'college_name': '電機資訊學院',
              'department_name': '資訊工程學系',
              'course_type': 'REQUIRED',
            },
          ],
        },
      });
    final repository = StaticRemoteCourseRepository(dio: dio);

    final result = await repository.searchCourses(
      keyword: '日文',
      instructor: '王中成',
      courseType: 'ELECTIVE',
      hasVacancy: true,
      limit: 1,
    );

    expect(result.totalCount, 1);
    expect(result.lastUpdated, isNotNull);
    expect(result.courses.single.serialNo, '00001');
    expect(result.courses.single.credit, 3);
  });

  test(
    'StaticRemoteCourseSupplementalDetailRepository loads detail json',
    () async {
      final detailUrl = '$staticRemoteCourseDetailsBaseUrl/00001.json';
      final dio = Dio()
        ..httpClientAdapter = _FakeJsonAdapter({
          detailUrl: {
            'serial_no': '00001',
            'objectives': '課程目標',
            'content': '課程內容',
            'books': '指定用書',
            'teaching_method': '講授',
            'grading_policy': '期中考30%',
            'distribution_conditions': [
              {'priority': 1, 'rule': '學制:限學士班。'},
              {'priority': 1, 'rule': '學制:限學士班。'},
            ],
          },
        });
      final repository = StaticRemoteCourseSupplementalDetailRepository(
        dio: dio,
      );

      final detail = await repository.findBySerialNo('00001');

      expect(detail, isNotNull);
      expect(detail!.serialNo, '00001');
      expect(detail.objectives, '課程目標');
      expect(detail.gradingPolicy, '期中考30%');
      expect(detail.distributionConditions, hasLength(2));
      expect(detail.distributionConditionText, '1：學制:限學士班。');
    },
  );

  test(
    'StaticRemoteCourseSupplementalDetailRepository pads numeric detail keys',
    () async {
      final detailUrl = '$staticRemoteCourseDetailsBaseUrl/00003.json';
      final dio = Dio()
        ..httpClientAdapter = _FakeJsonAdapter({
          detailUrl: {
            'serial_no': '00003',
            'objectives': '第三門課',
            'content': '',
            'books': '',
            'teaching_method': '',
            'grading_policy': '',
          },
        });
      final repository = StaticRemoteCourseSupplementalDetailRepository(
        dio: dio,
      );

      final detail = await repository.findBySerialNo('3');

      expect(detail, isNotNull);
      expect(detail!.serialNo, '00003');
      expect(detail.objectives, '第三門課');
    },
  );
}

class _FakeJsonAdapter implements HttpClientAdapter {
  _FakeJsonAdapter(this.responses);

  final Map<String, Object?> responses;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = responses[options.uri.toString()];
    if (response == null) {
      return ResponseBody.fromString('Not found', 404);
    }
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
