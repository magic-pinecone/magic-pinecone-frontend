import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';

void main() {
  group('CourseSelectionController', () {
    test('loads courses from repository', () async {
      final repository = FakeCourseRepository(
        result: const CourseSearchResult(
          totalCount: 1,
          courses: [
            CourseItem(
              serialNo: '12345',
              classNo: 'CS101',
              title: '程式設計',
              credit: 3,
              teachers: ['王小明'],
              classTimes: ['1-1', '1-2'],
            ),
          ],
        ),
      );
      final controller = CourseSelectionController(repository: repository);

      await controller.load();

      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      expect(controller.totalCount, 1);
      expect(controller.courses.single.title, '程式設計');
    });

    test('passes search keyword and course type to repository', () async {
      final repository = FakeCourseRepository();
      final controller = CourseSelectionController(repository: repository);

      await controller.search(keyword: '資料結構');
      await controller.setCourseType('REQUIRED');

      expect(repository.requests.last.keyword, '資料結構');
      expect(repository.requests.last.courseType, 'REQUIRED');
    });

    test('stores error when repository throws', () async {
      final controller = CourseSelectionController(
        repository: FakeCourseRepository(error: StateError('failed')),
      );

      await controller.load();

      expect(controller.isLoading, isFalse);
      expect(controller.error, isA<StateError>());
      expect(controller.courses, isEmpty);
    });
  });
}

class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository({
    this.result = const CourseSearchResult(totalCount: 0, courses: []),
    this.error,
  });

  final CourseSearchResult result;
  final Object? error;
  final List<CourseSearchRequest> requests = [];

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
    requests.add(
      CourseSearchRequest(
        keyword: keyword,
        classNo: classNo,
        serialNo: serialNo,
        departmentId: departmentId,
        collegeId: collegeId,
        courseType: courseType,
        offset: offset,
        limit: limit,
      ),
    );
    if (error != null) throw error!;
    return result;
  }
}

class CourseSearchRequest {
  const CourseSearchRequest({
    this.keyword,
    this.classNo,
    this.serialNo,
    this.departmentId,
    this.collegeId,
    this.courseType,
    required this.offset,
    required this.limit,
  });

  final String? keyword;
  final String? classNo;
  final String? serialNo;
  final String? departmentId;
  final String? collegeId;
  final String? courseType;
  final int offset;
  final int limit;
}
