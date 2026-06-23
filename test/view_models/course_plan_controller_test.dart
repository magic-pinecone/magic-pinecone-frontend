import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/course_selection/course_selection_providers.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_selection_storage.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_repository.dart';
import 'package:magic_pinecone/features/course_selection/domain/usecases/course_share_codec.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_plan_controller.dart';

void main() {
  group('CoursePlanController', () {
    test('tracks selected courses and local selected-course filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(coursePlanControllerProvider.notifier);
      CoursePlanState state() => container.read(coursePlanControllerProvider);

      controller.toggleCourseSelection(_programmingCourse);
      controller.setLocalFilters(
        onlyShowTimetableCompatibleCourses: false,
        onlyShowSelectedCourses: true,
      );

      expect(state().selectedCourses.keys, ['12345']);
      expect(state().selectedTotalCredits, 3);
      expect(state().hasUnsavedCourseSelection, isTrue);
      expect(
        controller.displayedCourses([_programmingCourse, _historyCourse]),
        [_programmingCourse],
      );
      expect(controller.localFilterTotalCount(2), 1);
    });

    test('filters courses that cannot fit the current timetable', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(coursePlanControllerProvider.notifier);

      controller.toggleCourseSelection(_programmingCourse);
      controller.setLocalFilters(
        onlyShowTimetableCompatibleCourses: true,
        onlyShowSelectedCourses: false,
      );

      final displayedCourses = controller.displayedCourses([
        _overlappingCourse,
        _historyCourse,
      ]);

      expect(displayedCourses, [_historyCourse]);
    });

    test('save persists share code and clears unsaved state', () async {
      final storage = MemoryCourseSelectionStorage();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(coursePlanControllerProvider.notifier);
      CoursePlanState state() => container.read(coursePlanControllerProvider);

      controller.toggleCourseSelection(_programmingCourse);

      await controller.saveCourseSelection(storage: storage);

      expect(
        const CourseShareCodec().decodeSerialNos(
          (await storage.readShareCode())!,
        ),
        ['12345'],
      );
      expect(state().hasUnsavedCourseSelection, isFalse);
      expect(state().canSaveCourseSelection, isFalse);
    });

    test(
      'restores shared preview without overwriting stored selection',
      () async {
        final storedCode = const CourseShareCodec().encodeSerialNos(['54321']);
        final previewCode = const CourseShareCodec().encodeSerialNos(['12345']);
        final storage = MemoryCourseSelectionStorage();
        await storage.writeShareCode(storedCode);
        final repository = FakeCourseRepository(
          result: const CourseSearchResult(
            totalCount: 1,
            courses: [_programmingCourse],
          ),
        );
        final container = ProviderContainer(
          overrides: [courseRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          coursePlanControllerProvider.notifier,
        );
        CoursePlanState state() => container.read(coursePlanControllerProvider);

        final result = await controller.restoreInitialSelection(
          storage: storage,
          initialShareCode: previewCode,
          baseUri: Uri.parse('https://example.com/course'),
        );

        expect(result.restored, isTrue);
        expect(result.preview, isTrue);
        expect(state().selectedCourses.keys, ['12345']);
        expect(state().isPreviewingSharedCourses, isTrue);
        expect(state().hasUnsavedCourseSelection, isFalse);
        expect(await storage.readShareCode(), storedCode);
      },
    );
  });
}

const _programmingCourse = CourseItem(
  serialNo: '12345',
  classNo: 'CS101',
  title: '程式設計',
  credit: 3,
  teachers: ['王小明'],
  classTimes: ['1-1', '1-2'],
);

const _overlappingCourse = CourseItem(
  serialNo: '23456',
  classNo: 'CS102',
  title: '資料結構',
  credit: 3,
  teachers: ['李小華'],
  classTimes: ['1-2'],
);

const _historyCourse = CourseItem(
  serialNo: '54321',
  classNo: 'HI101',
  title: '歷史',
  credit: 2,
  teachers: ['陳小美'],
  classTimes: ['3-1'],
);

class FakeCourseRepository implements CourseRepository {
  const FakeCourseRepository({
    this.result = const CourseSearchResult(totalCount: 0, courses: []),
  });

  final CourseSearchResult result;

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
    return result;
  }
}
