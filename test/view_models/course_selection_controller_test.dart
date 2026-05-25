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

    test('passes search keyword and filters to repository', () async {
      final repository = FakeCourseRepository();
      final controller = CourseSelectionController(repository: repository);

      await controller.search(keyword: '  資料結構  ');
      await controller.setCourseType('REQUIRED');
      await controller.toggleCredit(4);
      await controller.toggleCredit(2);
      await controller.setHasVacancy(true);
      await controller.toggleClassTime('5-2');
      await controller.toggleClassTime('1-1');

      expect(repository.requests.last.keyword, '資料結構');
      expect(repository.requests.last.courseType, 'REQUIRED');
      expect(repository.requests.last.credits, [2, 4]);
      expect(repository.requests.last.hasVacancy, isTrue);
      expect(repository.requests.last.classTimes, ['1-1', '5-2']);
      expect(controller.hasActiveFilter, isTrue);
    });

    test('clearFilters resets every filter and reloads once', () async {
      final repository = FakeCourseRepository();
      final controller = CourseSelectionController(repository: repository);

      await controller.search(keyword: '資料結構');
      await controller.setCourseType('REQUIRED');
      await controller.toggleCredit(3);
      await controller.setHasVacancy(true);
      await controller.toggleClassTime('1-1');

      final requestCountBeforeClear = repository.requests.length;

      await controller.clearFilters();

      expect(repository.requests, hasLength(requestCountBeforeClear + 1));
      expect(controller.keyword, isEmpty);
      expect(controller.courseType, isNull);
      expect(controller.credits, isEmpty);
      expect(controller.hasVacancy, isNull);
      expect(controller.classTimes, isEmpty);
      expect(controller.hasActiveFilter, isFalse);
      expect(repository.requests.last.keyword, isEmpty);
      expect(repository.requests.last.courseType, isNull);
      expect(repository.requests.last.credits, isEmpty);
      expect(repository.requests.last.hasVacancy, isNull);
      expect(repository.requests.last.classTimes, isEmpty);
    });

    test('clearFilters is a no-op when no filters are active', () async {
      final repository = FakeCourseRepository();
      final controller = CourseSelectionController(repository: repository);

      await controller.clearFilters();

      expect(repository.requests, isEmpty);
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

    test('failed refresh keeps previous results visible', () async {
      final repository = FakeCourseRepository(
        results: [
          const CourseSearchResult(
            totalCount: 1,
            courses: [
              CourseItem(
                serialNo: '12345',
                classNo: 'CS101',
                title: '程式設計',
                credit: 3,
                teachers: ['王小明'],
                classTimes: ['1-1'],
              ),
            ],
          ),
        ],
        errors: [StateError('network failed')],
      );
      final controller = CourseSelectionController(repository: repository);

      await controller.load();
      await controller.search();

      expect(controller.isLoading, isFalse);
      expect(controller.error, isA<StateError>());
      expect(controller.courses.single.title, '程式設計');
      expect(controller.totalCount, 1);
    });
  });
}

class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository({
    this.result = const CourseSearchResult(totalCount: 0, courses: []),
    this.error,
    List<CourseSearchResult>? results,
    List<Object>? errors,
  }) : _results = List<CourseSearchResult>.of(results ?? const []),
       _errors = List<Object>.of(errors ?? const []);

  final CourseSearchResult result;
  final Object? error;
  final List<CourseSearchResult> _results;
  final List<Object> _errors;
  final List<CourseSearchRequest> requests = [];

  @override
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentId,
    String? collegeId,
    String? courseType,
    List<int>? credits,
    bool? hasVacancy,
    List<String>? classTimes,
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
        credits: credits,
        hasVacancy: hasVacancy,
        classTimes: classTimes,
        offset: offset,
        limit: limit,
      ),
    );
    if (_results.isNotEmpty) return _results.removeAt(0);
    if (_errors.isNotEmpty) throw _errors.removeAt(0);
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
    this.credits,
    this.hasVacancy,
    this.classTimes,
    required this.offset,
    required this.limit,
  });

  final String? keyword;
  final String? classNo;
  final String? serialNo;
  final String? departmentId;
  final String? collegeId;
  final String? courseType;
  final List<int>? credits;
  final bool? hasVacancy;
  final List<String>? classTimes;
  final int offset;
  final int limit;
}
