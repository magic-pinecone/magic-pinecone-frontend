import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/features/course_selection/course_selection_providers.dart';
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
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_search_view.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_timetable_view.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/local_course_filter_sheet.dart';
import 'package:magic_pinecone/features/settings/presentation/settings_dialog.dart';
import 'package:magic_pinecone/features/settings/presentation/settings_page.dart';
import 'package:magic_pinecone/features/settings/presentation/view_models/settings_view_model.dart';

enum CourseSelectionNavigationMode { bottomNavigation, drawer }

class CourseSelectionExtraDestination {
  const CourseSelectionExtraDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.builder,
    this.hidesFloatingActions = true,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
  final WidgetBuilder builder;
  final bool hidesFloatingActions;
}

class CourseSelectionShell extends ConsumerStatefulWidget {
  const CourseSelectionShell({
    super.key,
    this.courseSelectionStorage,
    this.initialShareCode,
    this.showBackButton = false,
    this.title = '神奇松果 Lite',
    this.navigationMode = CourseSelectionNavigationMode.bottomNavigation,
    this.showSettingsDestination = true,
    this.extraDestination,
  });

  final CourseSelectionStorage? courseSelectionStorage;
  final String? initialShareCode;
  final bool showBackButton;
  final String title;
  final CourseSelectionNavigationMode navigationMode;
  final bool showSettingsDestination;
  final CourseSelectionExtraDestination? extraDestination;

  @override
  ConsumerState<CourseSelectionShell> createState() =>
      _CourseSelectionShellState();
}

enum _CourseSelectionView { search, timetable, settings, extra }

class _CourseSelectionShellState extends ConsumerState<CourseSelectionShell> {
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

  late CourseSelectionState _state;
  late CourseSelectionController _notifier;
  late SettingsState _settingsState;

  List<_CourseSelectionView> get _availableViews {
    return [
      _CourseSelectionView.search,
      _CourseSelectionView.timetable,
      if (widget.showSettingsDestination) _CourseSelectionView.settings,
      if (widget.extraDestination != null) _CourseSelectionView.extra,
    ];
  }

  @override
  void initState() {
    super.initState();
    _courseSelectionStorage =
        widget.courseSelectionStorage ?? createCourseSelectionStorage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(courseSelectionControllerProvider.notifier).load());
    });
  }

  @override
  Widget build(BuildContext context) {
    _state = ref.watch(courseSelectionControllerProvider);
    _notifier = ref.read(courseSelectionControllerProvider.notifier);
    _settingsState = ref.watch(settingsViewModelProvider);
    final supplementalDetailRepository = ref.watch(
      courseSupplementalDetailRepositoryProvider,
    );

    if (_state.isLoading && _state.courses.isEmpty) {
      _courseScheduledCoursesCache.clear();
      _canSyncToTimetableCache.clear();
    }
    if (!_state.isLoading && !_didRestoreSelectedCourses) {
      _didRestoreSelectedCourses = true;
      unawaited(_restoreSelectedCourses());
    }
    final displayedCourses = _displayedCourses();
    return LayoutBuilder(
      builder: (context, constraints) {
        final useDesktopWorkspace =
            constraints.maxWidth >=
            CourseSelectionLayout.desktopWorkspaceMinWidth;
        if (useDesktopWorkspace) {
          return _buildDesktopWorkspace(
            context,
            supplementalDetailRepository,
            displayedCourses,
          );
        }
        return _buildMobileWorkspace(
          context,
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
    CourseSupplementalDetailRepository supplementalDetailRepository,
    List<CourseItem> displayedCourses, {
    required bool useDesktopCourseDetails,
  }) {
    return Scaffold(
      appBar: AppBar(
        leading: _buildMobileLeading(),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedView == _CourseSelectionView.search)
            IconButton(
              tooltip: '重新整理',
              onPressed: _state.isLoading
                  ? null
                  : () => unawaited(_notifier.search()),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: switch (_selectedView) {
        _CourseSelectionView.search => _buildCourseSearchView(
          supplementalDetailRepository,
          displayedCourses,
          useDesktopCourseDetails: useDesktopCourseDetails,
          useAdvancedFilterDialog: useDesktopCourseDetails,
        ),
        _CourseSelectionView.timetable => _buildTimetableView(
          context,
          supplementalDetailRepository,
          useDesktopDialog: useDesktopCourseDetails,
        ),
        _CourseSelectionView.settings => const SettingsPage(showAppBar: false),
        _CourseSelectionView.extra => widget.extraDestination!.builder(context),
      },
      floatingActionButton: _buildMobileCourseSelectionActions(),
      drawer: widget.navigationMode == CourseSelectionNavigationMode.drawer
          ? _buildNavigationDrawer()
          : null,
      bottomNavigationBar:
          widget.navigationMode ==
              CourseSelectionNavigationMode.bottomNavigation
          ? NavigationBar(
              selectedIndex: _availableViews.indexOf(_selectedView),
              onDestinationSelected: _selectViewAt,
              destinations: _availableViews
                  .map(_navigationDestination)
                  .toList(),
            )
          : null,
    );
  }

  Widget? _buildMobileLeading() {
    if (widget.showBackButton) return const BackButton();
    if (widget.navigationMode == CourseSelectionNavigationMode.drawer) {
      return Builder(
        builder: (context) => IconButton(
          tooltip: '切換課程工具',
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu),
        ),
      );
    }
    return null;
  }

  Widget _buildDesktopWorkspace(
    BuildContext context,
    CourseSupplementalDetailRepository supplementalDetailRepository,
    List<CourseItem> displayedCourses,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: '重新整理',
            onPressed: _state.isLoading
                ? null
                : () => unawaited(_notifier.search()),
            icon: const Icon(Icons.refresh),
          ),
          if (widget.showSettingsDestination)
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
    CourseSupplementalDetailRepository supplementalDetailRepository, {
    required bool useDesktopDialog,
  }) {
    final snapshot = _visibleScheduleSnapshot();
    return CourseTimetableView(
      snapshot: snapshot,
      totalCredits: _selectedTotalCredits,
      conflictSlotCount: _conflictSlotCount(snapshot),
      showSaveAction: _canSaveCourseSelection && useDesktopDialog,
      showPreviewHint: _isPreviewingSharedCourses,
      onSavePressed: _saveCourseSelection,
      onDiscardPressed: () => unawaited(_discardUnsavedCourseSelection()),
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
        _selectedView == _CourseSelectionView.settings ||
        (_selectedView == _CourseSelectionView.extra &&
            widget.extraDestination!.hidesFloatingActions)) {
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
          onPressed: () => unawaited(_discardUnsavedCourseSelection()),
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

  NavigationDrawer _buildNavigationDrawer() {
    return NavigationDrawer(
      selectedIndex: _availableViews.indexOf(_selectedView),
      onDestinationSelected: (index) {
        Navigator.of(context).pop();
        _selectViewAt(index);
      },
      children: [
        const SizedBox(height: 12.0),
        for (final view in _availableViews) _drawerDestination(view),
      ],
    );
  }

  NavigationDestination _navigationDestination(_CourseSelectionView view) {
    return switch (view) {
      _CourseSelectionView.search => const NavigationDestination(
        icon: Icon(Icons.search),
        label: '課程查詢',
      ),
      _CourseSelectionView.timetable => const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: '課表',
      ),
      _CourseSelectionView.settings => const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: '設定',
      ),
      _CourseSelectionView.extra => NavigationDestination(
        icon: widget.extraDestination!.icon,
        selectedIcon: widget.extraDestination!.selectedIcon,
        label: widget.extraDestination!.label,
      ),
    };
  }

  NavigationDrawerDestination _drawerDestination(_CourseSelectionView view) {
    return switch (view) {
      _CourseSelectionView.search => const NavigationDrawerDestination(
        icon: Icon(Icons.search),
        label: Text('課程查詢'),
      ),
      _CourseSelectionView.timetable => const NavigationDrawerDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: Text('課表'),
      ),
      _CourseSelectionView.settings => const NavigationDrawerDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('設定'),
      ),
      _CourseSelectionView.extra => NavigationDrawerDestination(
        icon: widget.extraDestination!.icon,
        selectedIcon: widget.extraDestination!.selectedIcon,
        label: Text(widget.extraDestination!.label),
      ),
    };
  }

  void _selectViewAt(int index) {
    final views = _availableViews;
    if (index < 0 || index >= views.length) return;
    setState(() {
      _selectedView = views[index];
    });
  }

  Widget _buildCourseSearchView(
    CourseSupplementalDetailRepository supplementalDetailRepository,
    List<CourseItem> displayedCourses, {
    required bool useDesktopCourseDetails,
    required bool useAdvancedFilterDialog,
  }) {
    return CourseSearchView(
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
      localFilterTotalCount: _localFilterTotalCount(),
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

  List<CourseItem> _displayedCourses() {
    final courses = _onlyShowSelectedCourses
        ? _selectedCourses.values.toList(growable: false)
        : _state.courses;

    if (!_onlyShowTimetableCompatibleCourses) return courses;

    final currentSchedule = _syncedScheduleSnapshot();
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

  int _localFilterTotalCount() {
    if (_onlyShowSelectedCourses) return _selectedCourses.length;
    return _state.courses.length;
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

  Future<void> _restoreSelectedCourses() async {
    final restoreState = await _initialShareCode();
    if (restoreState == null) return;

    await _restoreCourseSelection(restoreState);
  }

  Future<void> _restoreCourseSelection(
    _CourseShareRestoreState restoreState,
  ) async {
    final serialNos = _decodeShareCode(restoreState.code);
    if (serialNos == null) return;

    final courses = await _notifier.findCoursesBySerialNos(serialNos);
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

  Future<void> _discardUnsavedCourseSelection() async {
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
    await _restoreCourseSelection(restoreState);
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

  CourseScheduleSnapshot _syncedScheduleSnapshot() {
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

  CourseScheduleSnapshot _visibleScheduleSnapshot() {
    final snapshot = _syncedScheduleSnapshot();
    if (!_settingsState.omitWeekendsOnTimetable) return snapshot;

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
