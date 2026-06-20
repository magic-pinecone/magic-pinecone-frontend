import 'package:flutter/foundation.dart';
import 'package:magic_pinecone/features/course_selection/course_selection_providers.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_selection_controller.g.dart';

class CourseSelectionState {
  const CourseSelectionState({
    this.courses = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.totalCount = 0,
    this.lastUpdated,
    this.keyword = '',
    this.classNo = '',
    this.serialNo = '',
    this.departmentName = '',
    this.collegeName = '',
    this.instructor = '',
    this.courseType,
    this.credits = const {},
    this.hasVacancy,
    this.classTimes = const {},
    this.offset = 0,
    this.limit = 50,
  });

  final List<CourseItem> courses;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;
  final int totalCount;
  final DateTime? lastUpdated;
  final String keyword;
  final String classNo;
  final String serialNo;
  final String departmentName;
  final String collegeName;
  final String instructor;
  final String? courseType;
  final Set<int> credits;
  final bool? hasVacancy;
  final Set<String> classTimes;
  final int offset;
  final int limit;

  List<int> get sortedCredits => credits.toList()..sort();
  List<String> get sortedClassTimes => classTimes.toList()..sort();

  bool hasCredit(int credit) => credits.contains(credit);
  int get currentPage => totalCount == 0 ? 0 : (offset ~/ limit) + 1;
  int get totalPages => totalCount == 0 ? 0 : ((totalCount - 1) ~/ limit) + 1;
  bool get canGoToPreviousPage => offset > 0;
  bool get canGoToNextPage => offset + courses.length < totalCount;

  int get activeFilterCount {
    return [
      keyword.isNotEmpty,
      classNo.isNotEmpty,
      serialNo.isNotEmpty,
      departmentName.isNotEmpty,
      collegeName.isNotEmpty,
      instructor.isNotEmpty,
      courseType != null,
      credits.isNotEmpty,
      hasVacancy != null,
      classTimes.isNotEmpty,
    ].where((isActive) => isActive).length;
  }

  bool get hasActiveFilter => activeFilterCount > 0;

  CourseSelectionState copyWith({
    List<CourseItem>? courses,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
    int? totalCount,
    DateTime? lastUpdated,
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? instructor,
    String? courseType,
    bool clearCourseType = false,
    Set<int>? credits,
    bool? hasVacancy,
    bool clearHasVacancy = false,
    Set<String>? classTimes,
    int? offset,
    int? limit,
  }) {
    return CourseSelectionState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      totalCount: totalCount ?? this.totalCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      keyword: keyword ?? this.keyword,
      classNo: classNo ?? this.classNo,
      serialNo: serialNo ?? this.serialNo,
      departmentName: departmentName ?? this.departmentName,
      collegeName: collegeName ?? this.collegeName,
      instructor: instructor ?? this.instructor,
      courseType: clearCourseType ? null : (courseType ?? this.courseType),
      credits: credits ?? this.credits,
      hasVacancy: clearHasVacancy ? null : (hasVacancy ?? this.hasVacancy),
      classTimes: classTimes ?? this.classTimes,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }
}

@riverpod
class CourseSelectionController extends _$CourseSelectionController {
  static const defaultPageSize = 50;

  @override
  CourseSelectionState build() {
    return const CourseSelectionState();
  }

  Future<void> load() {
    return search();
  }

  Future<void> search({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? instructor,
  }) async {
    final nextState = state.copyWith(
      keyword: keyword?.trim(),
      classNo: classNo?.trim(),
      serialNo: serialNo?.trim(),
      departmentName: departmentName?.trim(),
      collegeName: collegeName?.trim(),
      instructor: instructor?.trim(),
      offset: 0,
      isLoading: true,
      clearError: true,
    );
    state = nextState;

    try {
      final result = await ref
          .read(searchCoursesUseCaseProvider)
          .execute(
            keyword: state.keyword,
            classNo: state.classNo,
            serialNo: state.serialNo,
            departmentName: state.departmentName,
            collegeName: state.collegeName,
            instructor: state.instructor,
            courseType: state.courseType,
            credits: state.sortedCredits,
            hasVacancy: state.hasVacancy,
            classTimes: state.sortedClassTimes,
            offset: state.offset,
            limit: state.limit,
          );
      state = state.copyWith(
        courses: List.unmodifiable(result.courses),
        totalCount: result.totalCount,
        lastUpdated: result.lastUpdated,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(error: error, isLoading: false);
    }
  }

  Future<void> applyFilters({
    required String classNo,
    required String serialNo,
    required String departmentName,
    required String collegeName,
    required String instructor,
    required String? courseType,
    required Iterable<int> credits,
    required bool? hasVacancy,
    required Iterable<String> classTimes,
  }) async {
    state = state.copyWith(
      classNo: classNo.trim(),
      serialNo: serialNo.trim(),
      departmentName: departmentName.trim(),
      collegeName: collegeName.trim(),
      instructor: instructor.trim(),
      courseType: courseType,
      clearCourseType: courseType == null,
      credits: credits.toSet(),
      hasVacancy: hasVacancy,
      clearHasVacancy: hasVacancy == null,
      classTimes: classTimes.toSet(),
    );
    await search();
  }

  Future<void> nextPage() async {
    if (!state.canGoToNextPage) return;
    await _loadPage(state.offset + state.limit);
  }

  Future<void> previousPage() async {
    if (!state.canGoToPreviousPage) return;
    await _loadPage((state.offset - state.limit).clamp(0, state.offset));
  }

  Future<void> _loadPage(int offset) async {
    if (state.isLoading || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final result = await ref
          .read(searchCoursesUseCaseProvider)
          .execute(
            keyword: state.keyword,
            classNo: state.classNo,
            serialNo: state.serialNo,
            departmentName: state.departmentName,
            collegeName: state.collegeName,
            instructor: state.instructor,
            courseType: state.courseType,
            credits: state.sortedCredits,
            hasVacancy: state.hasVacancy,
            classTimes: state.sortedClassTimes,
            offset: offset,
            limit: state.limit,
          );
      state = state.copyWith(
        courses: List.unmodifiable(result.courses),
        totalCount: result.totalCount,
        lastUpdated: result.lastUpdated,
        offset: offset,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(error: error, isLoadingMore: false);
    }
  }

  Future<void> setCourseType(String? value) async {
    if (state.courseType == value) return;
    state = state.copyWith(courseType: value, clearCourseType: value == null);
    await search();
  }

  Future<void> toggleCredit(int value) async {
    final nextCredits = Set<int>.from(state.credits);
    if (!nextCredits.add(value)) {
      nextCredits.remove(value);
    }
    state = state.copyWith(credits: nextCredits);
    await search();
  }

  Future<void> setHasVacancy(bool? value) async {
    if (state.hasVacancy == value) return;
    state = state.copyWith(hasVacancy: value, clearHasVacancy: value == null);
    await search();
  }

  Future<void> toggleClassTime(String value) async {
    final nextClassTimes = Set<String>.from(state.classTimes);
    if (!nextClassTimes.add(value)) {
      nextClassTimes.remove(value);
    }
    state = state.copyWith(classTimes: nextClassTimes);
    await search();
  }

  Future<void> setClassTimes(Iterable<String> values) async {
    final nextValues = values.toSet();
    if (setEquals(state.classTimes, nextValues)) return;
    state = state.copyWith(classTimes: nextValues);
    await search();
  }

  Future<void> clearClassTimes() async {
    if (state.classTimes.isEmpty) return;
    state = state.copyWith(classTimes: const {});
    await search();
  }

  Future<void> clearFilters() async {
    if (!state.hasActiveFilter) return;
    state = const CourseSelectionState();
    await search();
  }

  Future<List<CourseItem>> findCoursesBySerialNos(Iterable<String> serialNos) {
    return ref
        .read(findCoursesBySerialNosUseCaseProvider)
        .execute(serialNos: serialNos, cachedCourses: state.courses);
  }
}
