import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/course_selection/data/dtos/course_dto.dart';

void main() {
  test('CourseResultDto parses backend course response', () {
    final result = CourseResultDto.fromJson(const {
      'total_count': 1,
      'last_updated': '2026-05-24T08:30:00Z',
      'courses': [
        {
          'serial_no': '53001',
          'class_no': 'CE1001-*',
          'title': '計算機概論I',
          'credit': 3.0,
          'password_card': null,
          'teachers': ['施國琛'],
          'class_times': ['4-1', '4-2', '4-3'],
          'limit_cnt': 130,
          'admit_cnt': 0,
          'wait_cnt': 0,
          'college_id': 'collegeI5',
          'department_id': 'deptI1I5002I0',
          'course_type': 'REQUIRED',
        },
      ],
    });

    expect(result.totalCount, 1);
    expect(result.lastUpdated, DateTime.utc(2026, 5, 24, 8, 30));
    expect(result.courses, hasLength(1));

    final course = result.courses.single;
    expect(course.serialNo, '53001');
    expect(course.classNo, 'CE1001-*');
    expect(course.title, '計算機概論I');
    expect(course.credit, 3.0);
    expect(course.passwordCard, isNull);
    expect(course.teachers, ['施國琛']);
    expect(course.classTimes, ['4-1', '4-2', '4-3']);
    expect(course.limitCnt, 130);
    expect(course.admitCnt, 0);
    expect(course.waitCnt, 0);
    expect(course.collegeId, 'collegeI5');
    expect(course.departmentId, 'deptI1I5002I0');
    expect(course.courseType, 'REQUIRED');
  });
}
