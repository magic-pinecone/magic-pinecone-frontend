import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_selection_storage.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_share_url.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_share_url_cleaner.dart';
import 'package:magic_pinecone/features/course_selection/data/repositories/course_schedule_repository_impl.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_schedule_repository.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_supplemental_detail_repository.dart';
import 'package:magic_pinecone/features/course_selection/domain/usecases/course_share_codec.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_layout.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_card_widgets.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_filter_widgets.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_result_widgets.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_state_widgets.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_timetable_view.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/local_course_filter_sheet.dart';
import 'package:magic_pinecone/features/settings/presentation/settings_dialog.dart';
import 'package:magic_pinecone/features/settings/presentation/view_models/settings_view_model.dart';

class LiteCourseSelectionPage extends ConsumerStatefulWidget {
  const LiteCourseSelectionPage({
    super.key,
    this.courseSelectionStorage,
    this.initialShareCode,
    this.showBackButton = false,
  });

  final CourseSelectionStorage? courseSelectionStorage;
  final String? initialShareCode;
  final bool showBackButton;

  @override
  ConsumerState<LiteCourseSelectionPage> createState() =>
      _LiteCourseSelectionPageState();
}

enum _CourseSelectionView { search, timetable, settings }

class _LiteCourseSelectionPageState
    extends ConsumerState<LiteCourseSelectionPage> {
  final CourseScheduleRepository _scheduleRepository =
      const StaticCourseScheduleRepository();
  final CourseShareCodec _shareCodec = const CourseShareCodec();
  final Map<String, CourseItem> _selectedCourses = {};
  _CourseSelectionView _selectedView = _CourseSelectionView.search;
  bool _onlyShowTimetableCompatibleCourses = false;
  bool _onlyShowSelectedCourses = false;
  bool _didRestoreSelectedCourses = false;
  bool _isPreviewingSharedCourses = false;
  bool _hasUnsavedCourseSelection = false;
  final Map<String, List<ScheduledCourse>> _courseScheduledCoursesCache = {};
  final Map<String, bool> _canSyncToTimetableCache = {};

  late final CourseSelectionStorage _courseSelectionStorage;

  @override
  void initState() {
    super.initState();
    _courseSelectionStorage =
        widget.courseSelectionStorage ?? createCourseSelectionStorage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(courseSelectionControllerProvider).load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(courseSelectionControllerProvider);
    final settingsViewModel = ref.watch(settingsViewModelProvider);
    final supplementalDetailRepository = ref.watch(
      courseSupplementalDetailRepositoryProvider,
    );

    if (controller.isLoading && controller.courses.isEmpty) {
      _courseScheduledCoursesCache.clear();
      _canSyncToTimetableCache.clear();
    }
    if (!controller.isLoading && !_didRestoreSelectedCourses) {
      _didRestoreSelectedCourses = true;
      unawaited(_restoreSelectedCourses(controller));
    }
    final displayedCourses = _displayedCourses(controller, settingsViewModel);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useDesktopWorkspace =
            constraints.maxWidth >=
            CourseSelectionLayout.desktopWorkspaceMinWidth;
        if (useDesktopWorkspace) {
          return _buildDesktopWorkspace(
            context,
            controller,
            settingsViewModel,
            supplementalDetailRepository,
            displayedCourses,
          );
        }
        return _buildMobileWorkspace(
          context,
          controller,
          settingsViewModel,
          supplementalDetailRepository,
          displayedCourses,
          useDesktopCourseDetails:
              constraints.maxWidth >= CourseSelectionLayout.wideLayoutMinWidth,
        );
      },
    );
  }

  Widget _buildMobileWorkspace(
    BuildContext context,
    CourseSelectionController controller,
    SettingsViewModel settingsViewModel,
    CourseSupplementalDetailRepository supplementalDetailRepository,
    List<CourseItem> displayedCourses, {
    required bool useDesktopCourseDetails,
  }) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton ? const BackButton() : null,
        title: const Text(
          '神奇松果 Lite',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedView == _CourseSelectionView.search)
            IconButton(
              tooltip: '重新整理',
              onPressed: controller.isLoading
                  ? null
                  : () => unawaited(controller.search()),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: switch (_selectedView) {
        _CourseSelectionView.search => _buildCourseSearchView(
          controller,
          supplementalDetailRepository,
          displayedCourses,
          useDesktopCourseDetails: useDesktopCourseDetails,
          useAdvancedFilterDialog: useDesktopCourseDetails,
        ),
        _CourseSelectionView.timetable => _buildTimetableView(
          context,
          settingsViewModel,
          supplementalDetailRepository,
          useDesktopDialog: useDesktopCourseDetails,
        ),
        _CourseSelectionView.settings => const SettingsPage(showAppBar: false),
      },
      floatingActionButton: _buildMobileCourseSelectionActions(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedView.index,
        onDestinationSelected: (index) {
          setState(() {
            _selectedView = _CourseSelectionView.values[index];
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: '課程查詢'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: '課表',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopWorkspace(
    BuildContext context,
    CourseSelectionController controller,
    SettingsViewModel settingsViewModel,
    CourseSupplementalDetailRepository supplementalDetailRepository,
    List<CourseItem> displayedCourses,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text(
          '神奇松果 Lite',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: '重新整理',
            onPressed: controller.isLoading
                ? null
                : () => unawaited(controller.search()),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: '設定',
            onPressed: () => _showSettingsDialog(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: CourseSelectionLayout.desktopCoursePaneWidth,
            child: _buildCourseSearchView(
              controller,
              supplementalDetailRepository,
              displayedCourses,
              useDesktopCourseDetails: true,
              useAdvancedFilterDialog: true,
            ),
          ),
          VerticalDivider(
            width: 1.0,
            thickness: 1.0,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: _buildTimetableView(
              context,
              settingsViewModel,
              supplementalDetailRepository,
              useDesktopDialog: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => const SettingsDialog(),
      ),
    );
  }

  Widget _buildTimetableView(
    BuildContext context,
    SettingsViewModel settingsViewModel,
    CourseSupplementalDetailRepository supplementalDetailRepository, {
    required bool useDesktopDialog,
  }) {
    final snapshot = _visibleScheduleSnapshot(settingsViewModel);
    return CourseTimetableView(
      snapshot: snapshot,
      totalCredits: _selectedTotalCredits,
      conflictSlotCount: _conflictSlotCount(snapshot),
      showSaveAction: _canSaveCourseSelection && useDesktopDialog,
      showPreviewHint: _isPreviewingSharedCourses,
      onSavePressed: _saveCourseSelection,
      onDiscardPressed: () => unawaited(
        _discardUnsavedCourseSelection(
          ref.read(courseSelectionControllerProvider),
        ),
      ),
      onSharePressed: _hasUnsavedCourseSelection ? null : _shareSelectedCourses,
      onCourseTap: (course) => _showTimetableCourseDetails(
        context,
        course,
        supplementalDetailRepository,
        useDesktopDialog: useDesktopDialog,
      ),
    );
  }

  Widget? _buildMobileCourseSelectionActions() {
    if (!_canSaveCourseSelection ||
        _selectedView == _CourseSelectionView.settings) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'restore-course-selection',
          tooltip: '還原課表',
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          onPressed: () => unawaited(
            _discardUnsavedCourseSelection(
              ref.read(courseSelectionControllerProvider),
            ),
          ),
          child: const Icon(Icons.restore),
        ),
        const SizedBox(height: 12.0),
        FloatingActionButton(
          heroTag: 'save-course-selection',
          tooltip: '儲存課表',
          onPressed: _saveCourseSelection,
          child: const Icon(Icons.save_outlined),
        ),
      ],
    );
  }

  Widget _buildCourseSearchView(
    CourseSelectionController controller,
    CourseSupplementalDetailRepository supplementalDetailRepository,
    List<CourseItem> displayedCourses, {
    required bool useDesktopCourseDetails,
    required bool useAdvancedFilterDialog,
  }) {
    return _CourseSearchView(
      controller: controller,
      displayedCourses: displayedCourses,
      isCourseSelected: _isCourseSelected,
      canSyncToTimetable: _canSyncToTimetable,
      onCourseTap: (course) => _showCourseDetails(
        context,
        course,
        supplementalDetailRepository,
        useDesktopDialog: useDesktopCourseDetails,
      ),
      onCourseSyncToggle: _toggleCourseSelection,
      onLocalFilterPressed: () =>
          _showLocalFilterSheet(context, useDialog: useAdvancedFilterDialog),
      localFilterActive:
          _onlyShowTimetableCompatibleCourses || _onlyShowSelectedCourses,
      localFilterTotalCount: _localFilterTotalCount(controller),
      useAdvancedFilterDialog: useAdvancedFilterDialog,
    );
  }

  void _showCourseDetails(
    BuildContext context,
    CourseItem course,
    CourseSupplementalDetailRepository supplementalDetailRepository, {
    required bool useDesktopDialog,
  }) {
    if (useDesktopDialog) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => CourseDetailsDialog(
            course: course,
            supplementalDetail: supplementalDetailRepository.findBySerialNo(
              course.serialNo,
            ),
            toggleCourseSelection: _toggleCourseSelection,
            isCourseSelected: _isCourseSelected,
          ),
        ),
      );
      return;
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => CourseDetailsSheet(
          course: course,
          toggleCourseSelection: _toggleCourseSelection,
          isCourseSelected: _isCourseSelected,
        ),
      ),
    );
  }

  void _showTimetableCourseDetails(
    BuildContext context,
    ScheduledCourse scheduledCourse,
    CourseSupplementalDetailRepository supplementalDetailRepository, {
    required bool useDesktopDialog,
  }) {
    final serialNo = scheduledCourse.serialNo;
    final course = serialNo == null ? null : _selectedCourses[serialNo];
    if (course != null) {
      _showCourseDetails(
        context,
        course,
        supplementalDetailRepository,
        useDesktopDialog: useDesktopDialog,
      );
      return;
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) =>
            ScheduledCourseDetailsSheet(course: scheduledCourse),
      ),
    );
  }

  Future<void> _showLocalFilterSheet(
    BuildContext context, {
    required bool useDialog,
  }) async {
    Widget buildContent(BuildContext context, {required bool useDialogLayout}) {
      return LocalCourseFilterSheet(
        onlyShowTimetableCompatibleCourses: _onlyShowTimetableCompatibleCourses,
        onlyShowSelectedCourses: _onlyShowSelectedCourses,
        useDialogLayout: useDialogLayout,
      );
    }

    final nextValue = useDialog
        ? await showDialog<LocalCourseFilterState>(
            context: context,
            builder: (context) {
              return Dialog(
                clipBehavior: Clip.antiAlias,
                insetPadding: const EdgeInsets.all(32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CourseSelectionLayout.maxSheetWidth,
                  ),
                  child: buildContent(context, useDialogLayout: true),
                ),
              );
            },
          )
        : await showModalBottomSheet<LocalCourseFilterState>(
            context: context,
            showDragHandle: true,
            builder: (context) {
              return buildContent(context, useDialogLayout: false);
            },
          );
    if (!mounted || nextValue == null) {
      return;
    }
    setState(() {
      _onlyShowTimetableCompatibleCourses =
          nextValue.onlyShowTimetableCompatibleCourses;
      _onlyShowSelectedCourses = nextValue.onlyShowSelectedCourses;
    });
  }

  List<ScheduledCourse> _getCachedScheduledCourses(
    CourseItem course,
    List<String> periods,
  ) {
    return _courseScheduledCoursesCache.putIfAbsent(
      course.serialNo,
      () => _courseToScheduledCourses(course, periods),
    );
  }

  List<CourseItem> _displayedCourses(
    CourseSelectionController controller,
    SettingsViewModel settingsViewModel,
  ) {
    final courses = _onlyShowSelectedCourses
        ? _selectedCourses.values.toList(growable: false)
        : controller.courses;

    if (!_onlyShowTimetableCompatibleCourses) return courses;

    final currentSchedule = _syncedScheduleSnapshot(settingsViewModel);
    final occupiedSlots = currentSchedule.courses
        .expand(_occupiedSlots)
        .toSet();
    final periods = currentSchedule.periods;

    return courses
        .where(
          (course) =>
              _canFitCurrentTimetableCached(course, occupiedSlots, periods),
        )
        .toList(growable: false);
  }

  int _localFilterTotalCount(CourseSelectionController controller) {
    if (_onlyShowSelectedCourses) return _selectedCourses.length;
    return controller.courses.length;
  }

  bool _isCourseSelected(CourseItem course) {
    return _selectedCourses.containsKey(course.serialNo);
  }

  int get _selectedTotalCredits {
    return _selectedCourses.values.fold(
      0,
      (total, course) => total + course.credit,
    );
  }

  bool _canSyncToTimetable(CourseItem course) {
    return _canSyncToTimetableCache.putIfAbsent(course.serialNo, () {
      final baseSchedule = _scheduleRepository.loadSchedule();
      return _getCachedScheduledCourses(
        course,
        baseSchedule.periods,
      ).isNotEmpty;
    });
  }

  bool _canFitCurrentTimetableCached(
    CourseItem course,
    Set<String> occupiedSlots,
    List<String> periods,
  ) {
    final candidateCourses = _getCachedScheduledCourses(course, periods);
    if (candidateCourses.isEmpty) return false;

    final candidateSlots = candidateCourses.expand(_occupiedSlots);
    return candidateSlots.every((slot) => !occupiedSlots.contains(slot));
  }

  Iterable<String> _occupiedSlots(ScheduledCourse course) sync* {
    for (var index = 0; index < course.length; index++) {
      yield '${course.dayIndex}:${course.startPeriodIndex + index}';
    }
  }

  int _conflictSlotCount(CourseScheduleSnapshot snapshot) {
    final slotCounts = <String, int>{};
    for (final course in snapshot.courses) {
      for (final slot in _occupiedSlots(course)) {
        slotCounts.update(slot, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return slotCounts.values.where((count) => count > 1).length;
  }

  Future<void> _shareSelectedCourses() async {
    final shareUrl = _selectedCourseShareUrl();
    await Clipboard.setData(ClipboardData(text: shareUrl.toString()));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已複製分享連結：$shareUrl')));
  }

  Uri _selectedCourseShareUrl() {
    final code = _selectedCourseShareCode();
    return buildCourseShareUrl(baseUri: Uri.base, code: code);
  }

  String _selectedCourseShareCode() {
    return _shareCodec.encodeSerialNos(_selectedCourses.keys);
  }

  void _toggleCourseSelection(CourseItem course) {
    setState(() {
      if (_selectedCourses.containsKey(course.serialNo)) {
        _selectedCourses.remove(course.serialNo);
      } else {
        _selectedCourses[course.serialNo] = course;
      }
      _hasUnsavedCourseSelection = true;
    });
  }

  bool get _canSaveCourseSelection {
    return _isPreviewingSharedCourses || _hasUnsavedCourseSelection;
  }

  Future<void> _persistSelectedCourses() async {
    final code = _selectedCourseShareCode();
    await _courseSelectionStorage.writeShareCode(code);
  }

  Future<void> _restoreSelectedCourses(
    CourseSelectionController controller,
  ) async {
    final restoreState = await _initialShareCode();
    if (restoreState == null) return;

    await _restoreCourseSelection(controller, restoreState);
  }

  Future<void> _restoreCourseSelection(
    CourseSelectionController controller,
    _CourseShareRestoreState restoreState,
  ) async {
    final serialNos = _decodeShareCode(restoreState.code);
    if (serialNos == null) return;

    final courses = await controller.findCoursesBySerialNos(serialNos);
    if (!mounted || courses.isEmpty) return;

    if (restoreState.isPreview) {
      clearCourseShareCodeFromBrowserUrl();
    }

    setState(() {
      _isPreviewingSharedCourses = restoreState.isPreview;
      _hasUnsavedCourseSelection = false;
      if (restoreState.isPreview) {
        _selectedView = _CourseSelectionView.timetable;
      }
      _selectedCourses
        ..clear()
        ..addEntries(
          courses.map((course) => MapEntry(course.serialNo, course)),
        );
    });
    if (!restoreState.isPreview) {
      await _courseSelectionStorage.writeShareCode(restoreState.code);
    }
  }

  Future<void> _discardUnsavedCourseSelection(
    CourseSelectionController controller,
  ) async {
    final storedCode = await _courseSelectionStorage.readShareCode();
    final normalizedStoredCode = storedCode?.trim();
    if (normalizedStoredCode == null || normalizedStoredCode.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isPreviewingSharedCourses = false;
        _hasUnsavedCourseSelection = false;
        _selectedCourses.clear();
      });
      return;
    }

    final restoreState = _CourseShareRestoreState(
      code: normalizedStoredCode,
      isPreview: false,
    );
    await _restoreCourseSelection(controller, restoreState);
  }

  Future<void> _saveCourseSelection() async {
    await _persistSelectedCourses();
    if (!mounted) return;

    setState(() {
      _isPreviewingSharedCourses = false;
      _hasUnsavedCourseSelection = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已儲存課表')));
  }

  Future<_CourseShareRestoreState?> _initialShareCode() async {
    final sharedCode =
        widget.initialShareCode?.trim() ??
        Uri.base.queryParameters['c']?.trim();
    if (sharedCode != null && sharedCode.isNotEmpty) {
      return _CourseShareRestoreState(code: sharedCode, isPreview: true);
    }

    final storedCode = await _courseSelectionStorage.readShareCode();
    final normalizedStoredCode = storedCode?.trim();
    if (normalizedStoredCode == null || normalizedStoredCode.isEmpty) {
      return null;
    }
    return _CourseShareRestoreState(
      code: normalizedStoredCode,
      isPreview: false,
    );
  }

  List<String>? _decodeShareCode(String code) {
    try {
      return _shareCodec.decodeSerialNos(code);
    } on ArgumentError {
      return null;
    }
  }

  CourseScheduleSnapshot _syncedScheduleSnapshot(
    SettingsViewModel settingsViewModel,
  ) {
    final baseSchedule = _scheduleRepository.loadSchedule();
    final syncedCourses = _selectedCourses.values.expand(
      (course) => _getCachedScheduledCourses(course, baseSchedule.periods),
    );

    return CourseScheduleSnapshot(
      courses: [...baseSchedule.courses, ...syncedCourses],
      weekDays: baseSchedule.weekDays,
      periods: baseSchedule.periods,
    );
  }

  CourseScheduleSnapshot _visibleScheduleSnapshot(
    SettingsViewModel settingsViewModel,
  ) {
    final snapshot = _syncedScheduleSnapshot(settingsViewModel);
    if (!settingsViewModel.omitWeekendsOnTimetable) return snapshot;

    return CourseScheduleSnapshot(
      courses: snapshot.courses
          .where((course) => course.dayIndex < 5)
          .toList(growable: false),
      weekDays: snapshot.weekDays.take(5).toList(growable: false),
      periods: snapshot.periods,
    );
  }

  List<ScheduledCourse> _courseToScheduledCourses(
    CourseItem course,
    List<String> periods,
  ) {
    final slots = <_CourseTimeSlot>[];

    for (final classTime in course.classTimes) {
      final parts = classTime.split('-');
      if (parts.length != 2) continue;

      final day = int.tryParse(parts[0]);
      if (day == null || day < 1 || day > 7) continue;

      final periodIndex = periods.indexOf(parts[1]);
      if (periodIndex < 0) continue;

      slots.add(_CourseTimeSlot(dayIndex: day - 1, periodIndex: periodIndex));
    }

    slots.sort((a, b) {
      final dayComparison = a.dayIndex.compareTo(b.dayIndex);
      if (dayComparison != 0) return dayComparison;
      return a.periodIndex.compareTo(b.periodIndex);
    });

    final courses = <ScheduledCourse>[];
    var index = 0;
    while (index < slots.length) {
      final start = slots[index];
      var length = 1;
      index += 1;

      while (index < slots.length &&
          slots[index].dayIndex == start.dayIndex &&
          slots[index].periodIndex == start.periodIndex + length) {
        length += 1;
        index += 1;
      }

      courses.add(
        ScheduledCourse(
          name: course.title,
          serialNo: course.serialNo,
          dayIndex: start.dayIndex,
          startPeriodIndex: start.periodIndex,
          length: length,
          location: course.classNo,
          category: course.courseTypeText,
        ),
      );
    }

    return courses;
  }
}

class _CourseShareRestoreState {
  const _CourseShareRestoreState({required this.code, required this.isPreview});

  final String code;
  final bool isPreview;
}

class _CourseTimeSlot {
  const _CourseTimeSlot({required this.dayIndex, required this.periodIndex});

  final int dayIndex;
  final int periodIndex;
}

class _CourseSearchView extends StatelessWidget {
  const _CourseSearchView({
    required this.controller,
    required this.displayedCourses,
    required this.isCourseSelected,
    required this.canSyncToTimetable,
    required this.onCourseTap,
    required this.onCourseSyncToggle,
    required this.onLocalFilterPressed,
    required this.localFilterActive,
    required this.localFilterTotalCount,
    required this.useAdvancedFilterDialog,
  });

  final CourseSelectionController controller;
  final List<CourseItem> displayedCourses;
  final bool Function(CourseItem course) isCourseSelected;
  final bool Function(CourseItem course) canSyncToTimetable;
  final ValueChanged<CourseItem> onCourseTap;
  final ValueChanged<CourseItem> onCourseSyncToggle;
  final VoidCallback onLocalFilterPressed;
  final bool localFilterActive;
  final int localFilterTotalCount;
  final bool useAdvancedFilterDialog;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid =
            constraints.maxWidth >= CourseSelectionLayout.wideLayoutMinWidth;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CourseSelectionLayout.maxSearchContentWidth,
            ),
            child: Column(
              children: [
                CourseSearchPanel(
                  controller: controller,
                  useAdvancedFilterDialog: useAdvancedFilterDialog,
                ),
                CourseResultSummary(
                  controller: controller,
                  displayedCourseCount: displayedCourses.length,
                  localFilterActive: localFilterActive,
                  localFilterTotalCount: localFilterTotalCount,
                  onFilterPressed: onLocalFilterPressed,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.search,
                    child: CustomScrollView(
                      scrollCacheExtent: const ScrollCacheExtent.pixels(900.0),
                      slivers: [
                        if (controller.isLoading && controller.courses.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (controller.error != null &&
                            controller.courses.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: CourseErrorState(
                              onRetry: () => unawaited(controller.search()),
                            ),
                          )
                        else if (displayedCourses.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: CourseEmptyState(),
                          )
                        else if (useGrid)
                          CourseResultGrid(
                            courses: displayedCourses,
                            isCourseSelected: isCourseSelected,
                            canSyncToTimetable: canSyncToTimetable,
                            onCourseTap: onCourseTap,
                            onCourseSyncToggle: onCourseSyncToggle,
                          )
                        else
                          CourseResultList(
                            courses: displayedCourses,
                            isCourseSelected: isCourseSelected,
                            canSyncToTimetable: canSyncToTimetable,
                            onCourseTap: onCourseTap,
                            onCourseSyncToggle: onCourseSyncToggle,
                          ),
                        if (!localFilterActive && controller.totalCount > 0)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                CourseSelectionLayout.horizontalPadding,
                                4.0,
                                CourseSelectionLayout.horizontalPadding,
                                24.0,
                              ),
                              child: CoursePaginationControls(
                                controller: controller,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
