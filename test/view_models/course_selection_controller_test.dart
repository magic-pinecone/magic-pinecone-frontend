import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/course_selection/data/course_repository.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_selection_controller.dart';

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

      await controller.search(
        keyword: '  資料結構  ',
        classNo: '  CS  ',
        serialNo: '  12345  ',
        departmentName: '  資訊工程  ',
        collegeName: '  電機資訊  ',
        instructor: '  王小明  ',
      );
      await controller.setCourseType('REQUIRED');
      await controller.toggleCredit(4);
      await controller.toggleCredit(2);
      await controller.setHasVacancy(true);
      await controller.toggleClassTime('5-2');
      await controller.toggleClassTime('1-1');

      expect(repository.requests.last.keyword, '資料結構');
      expect(repository.requests.last.classNo, 'CS');
      expect(repository.requests.last.serialNo, '12345');
      expect(repository.requests.last.departmentName, '資訊工程');
      expect(repository.requests.last.collegeName, '電機資訊');
      expect(repository.requests.last.instructor, '王小明');
      expect(repository.requests.last.courseType, 'REQUIRED');
      expect(repository.requests.last.credits, [2, 4]);
      expect(repository.requests.last.hasVacancy, isTrue);
      expect(repository.requests.last.classTimes, ['1-1', '5-2']);
      expect(repository.requests.last.offset, 0);
      expect(
        repository.requests.last.limit,
        CourseSelectionController.defaultPageSize,
      );
      expect(controller.activeFilterCount, 10);
      expect(controller.hasActiveFilter, isTrue);
    });

    test('page navigation loads one result page at a time', () async {
      final repository = FakeCourseRepository(
        results: [
          const CourseSearchResult(
            totalCount: 51,
            courses: [
              CourseItem(
                serialNo: '12345',
                classNo: 'CS101',
                title: '程式設計',
                credit: 3,
                teachers: [],
                classTimes: [],
              ),
            ],
          ),
          const CourseSearchResult(
            totalCount: 51,
            courses: [
              CourseItem(
                serialNo: '12346',
                classNo: 'CS102',
                title: '資料結構',
                credit: 3,
                teachers: [],
                classTimes: [],
              ),
            ],
          ),
          const CourseSearchResult(
            totalCount: 51,
            courses: [
              CourseItem(
                serialNo: '12345',
                classNo: 'CS101',
                title: '程式設計',
                credit: 3,
                teachers: [],
                classTimes: [],
              ),
            ],
          ),
        ],
      );
      final controller = CourseSelectionController(repository: repository);

      await controller.search(keyword: '程式');
      await controller.nextPage();

      expect(controller.courses.map((course) => course.title), ['資料結構']);
      expect(controller.currentPage, 2);
      expect(controller.totalPages, 2);
      expect(controller.canGoToNextPage, isFalse);
      expect(controller.canGoToPreviousPage, isTrue);
      expect(repository.requests, hasLength(2));
      expect(repository.requests.last.keyword, '程式');
      expect(
        repository.requests.last.offset,
        CourseSelectionController.defaultPageSize,
      );
      expect(
        repository.requests.last.limit,
        CourseSelectionController.defaultPageSize,
      );

      await controller.previousPage();

      expect(controller.courses.single.title, '程式設計');
      expect(controller.currentPage, 1);
      expect(repository.requests.last.offset, 0);
    });

    test('passes full-course vacancy filter to repository', () async {
      final repository = FakeCourseRepository();
      final controller = CourseSelectionController(repository: repository);

      await controller.setHasVacancy(false);

      expect(controller.hasVacancy, isFalse);
      expect(controller.activeFilterCount, 1);
      expect(repository.requests.last.hasVacancy, isFalse);
    });

    test('setClassTimes replaces class-time filters in one search', () async {
      final repository = FakeCourseRepository();
      final controller = CourseSelectionController(repository: repository);

      await controller.setClassTimes(['5-2', '1-1']);

      expect(controller.classTimes, ['1-1', '5-2']);
      expect(controller.activeFilterCount, 1);
      expect(repository.requests, hasLength(1));
      expect(repository.requests.single.classTimes, ['1-1', '5-2']);
    });

    test('clearFilters resets every filter and reloads once', () async {
      final repository = FakeCourseRepository();
      final controller = CourseSelectionController(repository: repository);

      await controller.search(
        keyword: '資料結構',
        classNo: 'CS',
        serialNo: '12345',
        departmentName: '資訊工程',
        collegeName: '電機資訊',
        instructor: '王小明',
      );
      await controller.setCourseType('REQUIRED');
      await controller.toggleCredit(3);
      await controller.setHasVacancy(true);
      await controller.toggleClassTime('1-1');

      final requestCountBeforeClear = repository.requests.length;

      await controller.clearFilters();

      expect(repository.requests, hasLength(requestCountBeforeClear + 1));
      expect(controller.keyword, isEmpty);
      expect(controller.classNo, isEmpty);
      expect(controller.serialNo, isEmpty);
      expect(controller.departmentName, isEmpty);
      expect(controller.collegeName, isEmpty);
      expect(controller.instructor, isEmpty);
      expect(controller.courseType, isNull);
      expect(controller.credits, isEmpty);
      expect(controller.hasVacancy, isNull);
      expect(controller.classTimes, isEmpty);
      expect(controller.activeFilterCount, 0);
      expect(controller.hasActiveFilter, isFalse);
      expect(repository.requests.last.keyword, isEmpty);
      expect(repository.requests.last.classNo, isEmpty);
      expect(repository.requests.last.serialNo, isEmpty);
      expect(repository.requests.last.departmentName, isEmpty);
      expect(repository.requests.last.collegeName, isEmpty);
      expect(repository.requests.last.instructor, isEmpty);
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
    requests.add(
      CourseSearchRequest(
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
    this.departmentName,
    this.collegeName,
    this.instructor,
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
  final String? departmentName;
  final String? collegeName;
  final String? instructor;
  final String? courseType;
  final List<int>? credits;
  final bool? hasVacancy;
  final List<String>? classTimes;
  final int offset;
  final int limit;
}
