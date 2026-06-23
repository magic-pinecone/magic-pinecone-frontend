import 'package:magic_pinecone/features/course_selection/course_selection_providers.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_selection_storage.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_share_url.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_share_url_cleaner.dart';
import 'package:magic_pinecone/features/course_selection/data/repositories/course_schedule_repository_impl.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_schedule_repository.dart';
import 'package:magic_pinecone/features/course_selection/domain/usecases/course_plan_schedule_builder.dart';
import 'package:magic_pinecone/features/course_selection/domain/usecases/course_share_codec.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_plan_controller.g.dart';

class CoursePlanState {
  const CoursePlanState({
    this.selectedCourses = const {},
    this.onlyShowTimetableCompatibleCourses = false,
    this.onlyShowSelectedCourses = false,
    this.isPreviewingSharedCourses = false,
    this.hasUnsavedCourseSelection = false,
  });

  final Map<String, CourseItem> selectedCourses;
  final bool onlyShowTimetableCompatibleCourses;
  final bool onlyShowSelectedCourses;
  final bool isPreviewingSharedCourses;
  final bool hasUnsavedCourseSelection;

  int get selectedTotalCredits {
    return selectedCourses.values.fold(
      0,
      (total, course) => total + course.credit,
    );
  }

  bool get canSaveCourseSelection {
    return isPreviewingSharedCourses || hasUnsavedCourseSelection;
  }

  CoursePlanState copyWith({
    Map<String, CourseItem>? selectedCourses,
    bool? onlyShowTimetableCompatibleCourses,
    bool? onlyShowSelectedCourses,
    bool? isPreviewingSharedCourses,
    bool? hasUnsavedCourseSelection,
  }) {
    return CoursePlanState(
      selectedCourses: selectedCourses ?? this.selectedCourses,
      onlyShowTimetableCompatibleCourses:
          onlyShowTimetableCompatibleCourses ??
          this.onlyShowTimetableCompatibleCourses,
      onlyShowSelectedCourses:
          onlyShowSelectedCourses ?? this.onlyShowSelectedCourses,
      isPreviewingSharedCourses:
          isPreviewingSharedCourses ?? this.isPreviewingSharedCourses,
      hasUnsavedCourseSelection:
          hasUnsavedCourseSelection ?? this.hasUnsavedCourseSelection,
    );
  }
}

class CoursePlanRestoreResult {
  const CoursePlanRestoreResult({
    required this.restored,
    required this.preview,
  });

  final bool restored;
  final bool preview;
}

class _CourseShareRestoreState {
  const _CourseShareRestoreState({required this.code, required this.isPreview});

  final String code;
  final bool isPreview;
}

@riverpod
class CoursePlanController extends _$CoursePlanController {
  final CourseScheduleRepository _scheduleRepository =
      const StaticCourseScheduleRepository();
  final CourseShareCodec _shareCodec = const CourseShareCodec();
  final Map<String, bool> _canSyncToTimetableCache = {};
  late CoursePlanScheduleBuilder _scheduleBuilder;

  @override
  CoursePlanState build() {
    _scheduleBuilder = ref.watch(coursePlanScheduleBuilderProvider);
    return const CoursePlanState();
  }

  void clearCourseCaches() {
    _canSyncToTimetableCache.clear();
  }

  void setLocalFilters({
    required bool onlyShowTimetableCompatibleCourses,
    required bool onlyShowSelectedCourses,
  }) {
    state = state.copyWith(
      onlyShowTimetableCompatibleCourses: onlyShowTimetableCompatibleCourses,
      onlyShowSelectedCourses: onlyShowSelectedCourses,
    );
  }

  List<CourseItem> displayedCourses(List<CourseItem> courses) {
    final selectedCourses = state.selectedCourses;
    final visibleCourses = state.onlyShowSelectedCourses
        ? selectedCourses.values.toList(growable: false)
        : courses;

    if (!state.onlyShowTimetableCompatibleCourses) return visibleCourses;

    final currentSchedule = syncedScheduleSnapshot();

    final occupiedSlotIds = currentSchedule.courses
        .expand(_scheduleBuilder.occupiedSlots)
        .toSet();

    return visibleCourses
        .where(
          (course) => _scheduleBuilder.canFitCurrentTimetable(
            course: course,
            snapshot: currentSchedule,
            occupiedSlotIds: occupiedSlotIds,
          ),
        )
        .toList(growable: false);
  }

  int localFilterTotalCount(int courseCount) {
    if (state.onlyShowSelectedCourses) return state.selectedCourses.length;
    return courseCount;
  }

  bool isCourseSelected(CourseItem course) {
    return state.selectedCourses.containsKey(course.serialNo);
  }

  bool canSyncToTimetable(CourseItem course) {
    return _canSyncToTimetableCache.putIfAbsent(course.serialNo, () {
      final baseSchedule = _scheduleRepository.loadSchedule();
      return _scheduleBuilder.canSyncToTimetable(
        course: course,
        periods: baseSchedule.periods,
      );
    });
  }

  void toggleCourseSelection(CourseItem course) {
    final nextSelectedCourses = Map<String, CourseItem>.from(
      state.selectedCourses,
    );
    if (nextSelectedCourses.containsKey(course.serialNo)) {
      nextSelectedCourses.remove(course.serialNo);
    } else {
      nextSelectedCourses[course.serialNo] = course;
    }
    state = state.copyWith(
      selectedCourses: Map.unmodifiable(nextSelectedCourses),
      hasUnsavedCourseSelection: true,
    );
  }

  CourseScheduleSnapshot visibleScheduleSnapshot({required bool omitWeekends}) {
    final snapshot = syncedScheduleSnapshot();
    if (!omitWeekends) return snapshot;

    return _scheduleBuilder.omitWeekends(snapshot);
  }

  CourseScheduleSnapshot syncedScheduleSnapshot() {
    final baseSchedule = _scheduleRepository.loadSchedule();
    return _scheduleBuilder.buildSyncedSchedule(
      baseSchedule: baseSchedule,
      selectedCourses: state.selectedCourses.values,
    );
  }

  int conflictSlotCount(CourseScheduleSnapshot snapshot) {
    return _scheduleBuilder.conflictSlotCount(snapshot);
  }

  Uri selectedCourseShareUrl({required Uri baseUri}) {
    final code = selectedCourseShareCode();
    return buildCourseShareUrl(baseUri: baseUri, code: code);
  }

  String selectedCourseShareCode() {
    return _shareCodec.encodeSerialNos(state.selectedCourses.keys);
  }

  Future<CoursePlanRestoreResult> restoreInitialSelection({
    required CourseSelectionStorage storage,
    required String? initialShareCode,
    required Uri baseUri,
  }) async {
    final restoreState = await _initialShareCode(
      storage: storage,
      initialShareCode: initialShareCode,
      baseUri: baseUri,
    );
    if (restoreState == null) {
      return const CoursePlanRestoreResult(restored: false, preview: false);
    }

    final restored = await _restoreCourseSelection(
      storage: storage,
      restoreState: restoreState,
    );
    return CoursePlanRestoreResult(
      restored: restored,
      preview: restoreState.isPreview,
    );
  }

  Future<void> discardUnsavedCourseSelection({
    required CourseSelectionStorage storage,
  }) async {
    final storedCode = await storage.readShareCode();
    final normalizedStoredCode = storedCode?.trim();
    if (normalizedStoredCode == null || normalizedStoredCode.isEmpty) {
      state = state.copyWith(
        selectedCourses: const {},
        isPreviewingSharedCourses: false,
        hasUnsavedCourseSelection: false,
      );
      return;
    }

    await _restoreCourseSelection(
      storage: storage,
      restoreState: _CourseShareRestoreState(
        code: normalizedStoredCode,
        isPreview: false,
      ),
    );
  }

  Future<void> saveCourseSelection({
    required CourseSelectionStorage storage,
  }) async {
    final code = selectedCourseShareCode();
    await storage.writeShareCode(code);
    state = state.copyWith(
      isPreviewingSharedCourses: false,
      hasUnsavedCourseSelection: false,
    );
  }

  Future<_CourseShareRestoreState?> _initialShareCode({
    required CourseSelectionStorage storage,
    required String? initialShareCode,
    required Uri baseUri,
  }) async {
    final sharedCode =
        initialShareCode?.trim() ?? baseUri.queryParameters['c']?.trim();
    if (sharedCode != null && sharedCode.isNotEmpty) {
      return _CourseShareRestoreState(code: sharedCode, isPreview: true);
    }

    final storedCode = await storage.readShareCode();
    final normalizedStoredCode = storedCode?.trim();
    if (normalizedStoredCode == null || normalizedStoredCode.isEmpty) {
      return null;
    }
    return _CourseShareRestoreState(
      code: normalizedStoredCode,
      isPreview: false,
    );
  }

  Future<bool> _restoreCourseSelection({
    required CourseSelectionStorage storage,
    required _CourseShareRestoreState restoreState,
  }) async {
    final serialNos = _decodeShareCode(restoreState.code);
    if (serialNos == null) return false;

    final courses = await ref
        .read(courseSelectionControllerProvider.notifier)
        .findCoursesBySerialNos(serialNos);
    if (courses.isEmpty) return false;

    if (restoreState.isPreview) {
      clearCourseShareCodeFromBrowserUrl();
    }

    state = state.copyWith(
      selectedCourses: Map.unmodifiable(
        Map.fromEntries(
          courses.map((course) => MapEntry(course.serialNo, course)),
        ),
      ),
      isPreviewingSharedCourses: restoreState.isPreview,
      hasUnsavedCourseSelection: false,
    );
    if (!restoreState.isPreview) {
      await storage.writeShareCode(restoreState.code);
    }
    return true;
  }

  List<String>? _decodeShareCode(String code) {
    try {
      return _shareCodec.decodeSerialNos(code);
    } on ArgumentError {
      return null;
    }
  }
}
