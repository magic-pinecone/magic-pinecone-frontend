import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/core/navigation/app_routes.dart';
import 'package:prototype/core/widgets/owned_change_notifier_builder.dart';
import 'package:prototype/features/course_selection/data/course_schedule_repository.dart';
import 'package:prototype/features/course_selection/data/course_selection_storage.dart';
import 'package:prototype/features/course_selection/data/course_share_codec.dart';
import 'package:prototype/features/course_selection/data/course_supplemental_detail_catalog.dart';
import 'package:prototype/features/course_selection/models/course_detail_models.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:prototype/features/course_selection/presentation/widgets/calendar_item.dart';

class CourseSelectionPage extends StatelessWidget {
  const CourseSelectionPage({
    super.key,
    this.controller,
    this.courseSupplementalDetailRepository,
    this.courseSelectionStorage,
    this.initialShareCode,
    this.showBackButton = false,
  });

  final CourseSelectionController? controller;
  final CourseSupplementalDetailRepository? courseSupplementalDetailRepository;
  final CourseSelectionStorage? courseSelectionStorage;
  final String? initialShareCode;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final dependencies = controller == null ? AppScope.of(context) : null;
    final supplementalDetailRepository =
        courseSupplementalDetailRepository ??
        dependencies?.courseSupplementalDetailRepository ??
        const StaticFallbackCourseSupplementalDetailRepository();
    final courseSelectionStorage =
        this.courseSelectionStorage ?? createCourseSelectionStorage();

    return OwnedChangeNotifierBuilder<CourseSelectionController>(
      notifier: controller,
      create: (context) => (dependencies ?? AppScope.of(context))
          .createCourseSelectionController(),
      onReady: (controller) => unawaited(controller.load()),
      builder: (context, controller) => _CourseSelectionPageContent(
        controller: controller,
        supplementalDetailRepository: supplementalDetailRepository,
        courseSelectionStorage: courseSelectionStorage,
        initialShareCode: initialShareCode,
        showBackButton: showBackButton,
      ),
    );
  }
}

enum _CourseSelectionView { search, timetable, helper }

enum _CourseTypeFilter { all, required, elective }

enum _VacancyFilter { all, available, full }

class _CourseSelectionPageContent extends StatefulWidget {
  const _CourseSelectionPageContent({
    required this.controller,
    required this.supplementalDetailRepository,
    required this.courseSelectionStorage,
    required this.initialShareCode,
    required this.showBackButton,
  });

  final CourseSelectionController controller;
  final CourseSupplementalDetailRepository supplementalDetailRepository;
  final CourseSelectionStorage courseSelectionStorage;
  final String? initialShareCode;
  final bool showBackButton;

  @override
  State<_CourseSelectionPageContent> createState() =>
      _CourseSelectionPageContentState();
}

class _CourseSelectionPageContentState
    extends State<_CourseSelectionPageContent> {
  static const _horizontalPadding = 16.0;
  static const _wideLayoutMinWidth = 900.0;
  static const _desktopWorkspaceMinWidth = 1100.0;
  static const _desktopCoursePaneWidth = 520.0;
  static const _maxSearchContentWidth = 1180.0;
  static const _maxSheetWidth = 640.0;
  static const _maxAdvancedFilterDialogWidth = 1080.0;
  static const _maxCourseDetailsDialogWidth = 980.0;
  static const _courseDetailsDialogHeight = 680.0;
  static const _courseGridMaxExtent = 560.0;

  final CourseScheduleRepository _scheduleRepository =
      const StaticCourseScheduleRepository();
  final CourseShareCodec _shareCodec = const CourseShareCodec();
  final InMemoryChatController _chatController = InMemoryChatController(
    messages: [
      TextMessage(
        id: 'helper-welcome',
        authorId: 'course-helper',
        createdAt: DateTime(2026),
        text: '你好，我是 AI 選課小幫手。可以先告訴我你的系級、想修的領域、可上課時段，或想避開的課程限制。',
      ),
    ],
  );
  final Map<String, CourseItem> _selectedCourses = {};
  _CourseSelectionView _selectedView = _CourseSelectionView.search;
  bool _onlyShowTimetableCompatibleCourses = false;
  bool _onlyShowSelectedCourses = false;
  int _messageSequence = 0;
  bool _didRestoreSelectedCourses = false;
  bool _isPreviewingSharedCourses = false;
  bool _hasUnsavedCourseSelection = false;
  final Map<String, List<ScheduledCourse>> _courseScheduledCoursesCache = {};
  final Map<String, bool> _canSyncToTimetableCache = {};

  CourseSelectionController get controller => widget.controller;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading && controller.courses.isEmpty) {
          _courseScheduledCoursesCache.clear();
          _canSyncToTimetableCache.clear();
        }
        if (!controller.isLoading && !_didRestoreSelectedCourses) {
          _didRestoreSelectedCourses = true;
          unawaited(_restoreSelectedCourses());
        }
        final displayedCourses = _displayedCourses();
        return LayoutBuilder(
          builder: (context, constraints) {
            final useDesktopWorkspace =
                constraints.maxWidth >= _desktopWorkspaceMinWidth;
            if (useDesktopWorkspace) {
              return _buildDesktopWorkspace(context, displayedCourses);
            }
            return _buildMobileWorkspace(
              context,
              displayedCourses,
              useDesktopCourseDetails:
                  constraints.maxWidth >= _wideLayoutMinWidth,
            );
          },
        );
      },
    );
  }

  Widget _buildMobileWorkspace(
    BuildContext context,
    List<CourseItem> displayedCourses, {
    required bool useDesktopCourseDetails,
  }) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? const BackButton()
            : Builder(
                builder: (context) => IconButton(
                  tooltip: '切換課程工具',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                ),
              ),
        title: const Text(
          '課程查詢',
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
      drawer: Builder(
        builder: (drawerContext) => NavigationDrawer(
          selectedIndex: _selectedView.index,
          onDestinationSelected: (index) {
            Navigator.of(drawerContext).pop();
            setState(() {
              _selectedView = _CourseSelectionView.values[index];
            });
          },
          children: const [
            SizedBox(height: 12.0),
            NavigationDrawerDestination(
              icon: Icon(Icons.search),
              label: Text('課程查詢'),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: Text('課表'),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy),
              label: Text('AI 選課小幫手'),
            ),
          ],
        ),
      ),
      body: switch (_selectedView) {
        _CourseSelectionView.search => _buildCourseSearchView(
          displayedCourses,
          useDesktopCourseDetails: useDesktopCourseDetails,
          useAdvancedFilterDialog: useDesktopCourseDetails,
        ),
        _CourseSelectionView.timetable => _buildTimetableView(
          context,
          useDesktopDialog: useDesktopCourseDetails,
        ),
        _CourseSelectionView.helper => _CourseHelperChatView(
          chatController: _chatController,
          onMessageSend: _sendHelperMessage,
        ),
      },
      floatingActionButton:
          _selectedView == _CourseSelectionView.search &&
              _canSaveCourseSelection
          ? FloatingActionButton(
              tooltip: '儲存課表',
              onPressed: _saveCourseSelection,
              child: const Icon(Icons.save_outlined),
            )
          : null,
    );
  }

  Widget _buildDesktopWorkspace(
    BuildContext context,
    List<CourseItem> displayedCourses,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text(
          '課程查詢',
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
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: _desktopCoursePaneWidth,
            child: _buildCourseSearchView(
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
          Expanded(child: _buildTimetableView(context, useDesktopDialog: true)),
        ],
      ),
    );
  }

  Widget _buildTimetableView(
    BuildContext context, {
    required bool useDesktopDialog,
  }) {
    final snapshot = _syncedScheduleSnapshot();
    return _CourseTimetableView(
      snapshot: snapshot,
      totalCredits: _selectedTotalCredits,
      conflictSlotCount: _conflictSlotCount(snapshot),
      showSaveAction: _canSaveCourseSelection,
      showPreviewHint: _isPreviewingSharedCourses,
      onSavePressed: _saveCourseSelection,
      onSharePressed: _shareSelectedCourses,
      onCourseTap: (course) => _showTimetableCourseDetails(
        context,
        course,
        useDesktopDialog: useDesktopDialog,
      ),
    );
  }

  Widget _buildCourseSearchView(
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
        useDesktopDialog: useDesktopCourseDetails,
      ),
      onCourseSyncToggle: _toggleCourseSelection,
      onLocalFilterPressed: () =>
          _showLocalFilterSheet(context, useDialog: useAdvancedFilterDialog),
      localFilterActive:
          _onlyShowTimetableCompatibleCourses || _onlyShowSelectedCourses,
      localFilterTotalCount: _localFilterTotalCount,
      useAdvancedFilterDialog: useAdvancedFilterDialog,
    );
  }

  void _showCourseDetails(
    BuildContext context,
    CourseItem course, {
    required bool useDesktopDialog,
  }) {
    if (useDesktopDialog) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => _CourseDetailsDialog(
            course: course,
            supplementalDetail: widget.supplementalDetailRepository
                .findBySerialNo(course.serialNo),
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
        builder: (context) => _CourseDetailsSheet(course: course),
      ),
    );
  }

  void _showTimetableCourseDetails(
    BuildContext context,
    ScheduledCourse scheduledCourse, {
    required bool useDesktopDialog,
  }) {
    final serialNo = scheduledCourse.serialNo;
    final course = serialNo == null ? null : _selectedCourses[serialNo];
    if (course != null) {
      _showCourseDetails(context, course, useDesktopDialog: useDesktopDialog);
      return;
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) =>
            _ScheduledCourseDetailsSheet(course: scheduledCourse),
      ),
    );
  }

  Future<void> _showLocalFilterSheet(
    BuildContext context, {
    required bool useDialog,
  }) async {
    Widget buildContent(BuildContext context, {required bool useDialogLayout}) {
      return _LocalCourseFilterSheet(
        onlyShowTimetableCompatibleCourses: _onlyShowTimetableCompatibleCourses,
        onlyShowSelectedCourses: _onlyShowSelectedCourses,
        useDialogLayout: useDialogLayout,
      );
    }

    final nextValue = useDialog
        ? await showDialog<_LocalCourseFilterState>(
            context: context,
            builder: (context) {
              return Dialog(
                clipBehavior: Clip.antiAlias,
                insetPadding: const EdgeInsets.all(32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxSheetWidth),
                  child: buildContent(context, useDialogLayout: true),
                ),
              );
            },
          )
        : await showModalBottomSheet<_LocalCourseFilterState>(
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
        : controller.courses;

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

  int get _localFilterTotalCount {
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
    return Uri.base.replace(
      path: '/share',
      queryParameters: {'c': code},
      fragment: '',
    );
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
    await widget.courseSelectionStorage.writeShareCode(code);
  }

  Future<void> _restoreSelectedCourses() async {
    final restoreState = await _initialShareCode();
    if (restoreState == null) return;

    final serialNos = _decodeShareCode(restoreState.code);
    if (serialNos == null) return;

    final courses = await controller.findCoursesBySerialNos(serialNos);
    if (!mounted || courses.isEmpty) return;

    setState(() {
      _isPreviewingSharedCourses = restoreState.isPreview;
      _hasUnsavedCourseSelection = false;
      _selectedCourses
        ..clear()
        ..addEntries(
          courses.map((course) => MapEntry(course.serialNo, course)),
        );
    });
    if (!restoreState.isPreview) {
      await widget.courseSelectionStorage.writeShareCode(restoreState.code);
    }
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

    final storedCode = await widget.courseSelectionStorage.readShareCode();
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

  void _sendHelperMessage(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final now = DateTime.now().toUtc();
    _messageSequence += 1;
    unawaited(
      _chatController.insertMessage(
        TextMessage(
          id: 'student-$_messageSequence',
          authorId: 'student',
          createdAt: now,
          text: trimmedText,
        ),
      ),
    );

    _messageSequence += 1;
    unawaited(
      _chatController.insertMessage(
        TextMessage(
          id: 'helper-$_messageSequence',
          authorId: 'course-helper',
          createdAt: now.add(const Duration(milliseconds: 1)),
          text:
              '我先記下你的需求：「$trimmedText」。之後可以在這裡接上後端或 AI API，依照課程查詢資料幫你篩選衝堂、學分與名額。',
        ),
      ),
    );
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
            constraints.maxWidth >=
            _CourseSelectionPageContentState._wideLayoutMinWidth;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _CourseSelectionPageContentState._maxSearchContentWidth,
            ),
            child: Column(
              children: [
                _SearchPanel(
                  controller: controller,
                  useAdvancedFilterDialog: useAdvancedFilterDialog,
                ),
                _ResultSummary(
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
                            child: _ErrorState(
                              onRetry: () => unawaited(controller.search()),
                            ),
                          )
                        else if (displayedCourses.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyState(),
                          )
                        else if (useGrid)
                          _CourseResultGrid(
                            courses: displayedCourses,
                            isCourseSelected: isCourseSelected,
                            canSyncToTimetable: canSyncToTimetable,
                            onCourseTap: onCourseTap,
                            onCourseSyncToggle: onCourseSyncToggle,
                          )
                        else
                          _CourseResultList(
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
                                _CourseSelectionPageContentState
                                    ._horizontalPadding,
                                4.0,
                                _CourseSelectionPageContentState
                                    ._horizontalPadding,
                                24.0,
                              ),
                              child: _CoursePaginationControls(
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

class _CourseResultList extends StatelessWidget {
  const _CourseResultList({
    required this.courses,
    required this.isCourseSelected,
    required this.canSyncToTimetable,
    required this.onCourseTap,
    required this.onCourseSyncToggle,
  });

  final List<CourseItem> courses;
  final bool Function(CourseItem course) isCourseSelected;
  final bool Function(CourseItem course) canSyncToTimetable;
  final ValueChanged<CourseItem> onCourseTap;
  final ValueChanged<CourseItem> onCourseSyncToggle;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        _CourseSelectionPageContentState._horizontalPadding,
        4.0,
        _CourseSelectionPageContentState._horizontalPadding,
        20.0,
      ),
      sliver: SliverList.separated(
        addAutomaticKeepAlives: false,
        itemCount: courses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8.0),
        itemBuilder: (context, index) {
          final course = courses[index];
          return _CourseListTile(
            course: course,
            isSelected: isCourseSelected(course),
            canSyncToTimetable: canSyncToTimetable(course),
            alignActionsToBottom: false,
            onTap: () => onCourseTap(course),
            onSyncToggle: () => onCourseSyncToggle(course),
          );
        },
      ),
    );
  }
}

class _CourseResultGrid extends StatelessWidget {
  const _CourseResultGrid({
    required this.courses,
    required this.isCourseSelected,
    required this.canSyncToTimetable,
    required this.onCourseTap,
    required this.onCourseSyncToggle,
  });

  final List<CourseItem> courses;
  final bool Function(CourseItem course) isCourseSelected;
  final bool Function(CourseItem course) canSyncToTimetable;
  final ValueChanged<CourseItem> onCourseTap;
  final ValueChanged<CourseItem> onCourseSyncToggle;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        _CourseSelectionPageContentState._horizontalPadding,
        4.0,
        _CourseSelectionPageContentState._horizontalPadding,
        20.0,
      ),
      sliver: SliverGrid.builder(
        addAutomaticKeepAlives: false,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent:
              _CourseSelectionPageContentState._courseGridMaxExtent,
          mainAxisExtent: 214.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return _CourseListTile(
            course: course,
            isSelected: isCourseSelected(course),
            canSyncToTimetable: canSyncToTimetable(course),
            alignActionsToBottom: true,
            onTap: () => onCourseTap(course),
            onSyncToggle: () => onCourseSyncToggle(course),
          );
        },
      ),
    );
  }
}

class _CoursePaginationControls extends StatelessWidget {
  const _CoursePaginationControls({required this.controller});

  final CourseSelectionController controller;

  @override
  Widget build(BuildContext context) {
    final isBusy = controller.isLoading || controller.isLoadingMore;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: isBusy || !controller.canGoToPreviousPage
              ? null
              : () => unawaited(controller.previousPage()),
          icon: const Icon(Icons.chevron_left),
          label: const Text('上一頁'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: controller.isLoadingMore
              ? const SizedBox.square(
                  dimension: 18.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : Text(
                  '${controller.currentPage} / ${controller.totalPages}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
        ),
        OutlinedButton.icon(
          onPressed: isBusy || !controller.canGoToNextPage
              ? null
              : () => unawaited(controller.nextPage()),
          icon: const Icon(Icons.chevron_right),
          label: const Text('下一頁'),
        ),
      ],
    );
  }
}

class _CourseHelperChatView extends StatelessWidget {
  const _CourseHelperChatView({
    required this.chatController,
    required this.onMessageSend,
  });

  final ChatController chatController;
  final void Function(String text) onMessageSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chat(
      chatController: chatController,
      currentUserId: 'student',
      backgroundColor: colorScheme.surface,
      onMessageSend: onMessageSend,
      resolveUser: (id) async {
        return switch (id) {
          'course-helper' => User(id: id, name: 'AI 選課小幫手'),
          _ => User(id: id, name: '我'),
        };
      },
    );
  }
}

class _CourseTimetableView extends StatelessWidget {
  const _CourseTimetableView({
    required this.snapshot,
    required this.totalCredits,
    required this.conflictSlotCount,
    required this.showSaveAction,
    required this.showPreviewHint,
    required this.onSavePressed,
    required this.onSharePressed,
    required this.onCourseTap,
  });

  static const _periodColumnWidth = 34.0;
  static const _maxDayColumnWidth = 118.0;
  static const _rowHeight = 48.0;
  static const _gridGap = 6.0;
  static const _headerHeight = 32.0;

  final CourseScheduleSnapshot snapshot;
  final int totalCredits;
  final int conflictSlotCount;
  final bool showSaveAction;
  final bool showPreviewHint;
  final VoidCallback onSavePressed;
  final VoidCallback onSharePressed;
  final ValueChanged<ScheduledCourse> onCourseTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalGapWidth = _gridGap * (snapshot.weekDays.length - 1);
                final availableWidth =
                    constraints.maxWidth -
                    _periodColumnWidth -
                    totalGapWidth -
                    24.0;
                final dayColumnWidth =
                    (availableWidth / snapshot.weekDays.length).clamp(
                      0.0,
                      _maxDayColumnWidth,
                    );
                final totalWidth =
                    _periodColumnWidth +
                    snapshot.weekDays.length * dayColumnWidth +
                    totalGapWidth;
                final gridHeight =
                    snapshot.periods.length * _rowHeight +
                    (snapshot.periods.length - 1) * _gridGap;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12.0, 58.0, 12.0, 20.0),
                  child: Center(
                    child: SizedBox(
                      width: totalWidth,
                      child: Column(
                        children: [
                          _TimetableHeader(
                            weekDays: snapshot.weekDays,
                            periodColumnWidth: _periodColumnWidth,
                            dayColumnWidth: dayColumnWidth,
                            gap: _gridGap,
                            height: _headerHeight,
                          ),
                          const SizedBox(height: _gridGap),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TimetablePeriods(
                                periods: snapshot.periods,
                                width: _periodColumnWidth,
                                rowHeight: _rowHeight,
                                gap: _gridGap,
                              ),
                              SizedBox(
                                width: totalWidth - _periodColumnWidth,
                                height: gridHeight,
                                child: Stack(
                                  children: [
                                    _TimetableGridBackground(
                                      dayCount: snapshot.weekDays.length,
                                      periodCount: snapshot.periods.length,
                                      dayColumnWidth: dayColumnWidth,
                                      rowHeight: _rowHeight,
                                      gap: _gridGap,
                                    ),
                                    for (final course in snapshot.courses)
                                      _PositionedScheduledCourse(
                                        course: course,
                                        dayColumnWidth: dayColumnWidth,
                                        rowHeight: _rowHeight,
                                        gap: _gridGap,
                                        onTap: onCourseTap,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 10.0,
            left: 12.0,
            right: 12.0,
            child: Align(
              alignment: Alignment.topCenter,
              child: _TimetableToolbar(
                totalCredits: totalCredits,
                conflictSlotCount: conflictSlotCount,
                showSaveAction: showSaveAction,
                showPreviewHint: showPreviewHint,
                onSavePressed: onSavePressed,
                onSharePressed: onSharePressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableToolbar extends StatelessWidget {
  const _TimetableToolbar({
    required this.totalCredits,
    required this.conflictSlotCount,
    required this.showSaveAction,
    required this.showPreviewHint,
    required this.onSavePressed,
    required this.onSharePressed,
  });

  final int totalCredits;
  final int conflictSlotCount;
  final bool showSaveAction;
  final bool showPreviewHint;
  final VoidCallback onSavePressed;
  final VoidCallback onSharePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasConflict = conflictSlotCount > 0;

    return Material(
      elevation: 4.0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.16),
      color: colorScheme.surface,
      shape: StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TimetableToolbarItem(
              icon: Icons.school_outlined,
              label: '$totalCredits 學分',
              foregroundColor: colorScheme.onSurface,
            ),
            _TimetableToolbarItem(
              icon: hasConflict
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              label: hasConflict ? '衝堂 $conflictSlotCount 節' : '無衝堂',
              foregroundColor: hasConflict
                  ? colorScheme.error
                  : colorScheme.primary,
            ),
            if (showPreviewHint)
              Tooltip(
                message: '預覽中，儲存後才會覆蓋本機課表。',
                child: _TimetableToolbarItem(
                  icon: Icons.visibility_outlined,
                  label: '預覽',
                  foregroundColor: colorScheme.tertiary,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                width: 1.0,
                height: 20.0,
                color: colorScheme.outlineVariant,
              ),
            ),
            if (showSaveAction)
              _TimetableToolbarTextAction(
                label: '儲存',
                onPressed: onSavePressed,
                foregroundColor: colorScheme.primary,
              ),
            _TimetableToolbarTextAction(
              label: '分享課表',
              onPressed: onSharePressed,
              foregroundColor: colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimetableToolbarTextAction extends StatelessWidget {
  const _TimetableToolbarTextAction({
    required this.label,
    required this.onPressed,
    required this.foregroundColor,
  });

  final String label;
  final VoidCallback onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimetableToolbarItem extends StatelessWidget {
  const _TimetableToolbarItem({
    required this.icon,
    required this.label,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.0, color: foregroundColor),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableHeader extends StatelessWidget {
  const _TimetableHeader({
    required this.weekDays,
    required this.periodColumnWidth,
    required this.dayColumnWidth,
    required this.gap,
    required this.height,
  });

  final List<String> weekDays;
  final double periodColumnWidth;
  final double dayColumnWidth;
  final double gap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: periodColumnWidth, height: height),
        for (var index = 0; index < weekDays.length; index++) ...[
          SizedBox(
            width: dayColumnWidth,
            height: height,
            child: Center(
              child: Text(
                '週${weekDays[index]}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
          if (index < weekDays.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _TimetablePeriods extends StatelessWidget {
  const _TimetablePeriods({
    required this.periods,
    required this.width,
    required this.rowHeight,
    required this.gap,
  });

  final List<String> periods;
  final double width;
  final double rowHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium;

    return Column(
      children: [
        for (var index = 0; index < periods.length; index++) ...[
          SizedBox(
            width: width,
            height: rowHeight,
            child: Center(child: Text(periods[index], style: textStyle)),
          ),
          if (index < periods.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class _TimetableGridBackground extends StatelessWidget {
  const _TimetableGridBackground({
    required this.dayCount,
    required this.periodCount,
    required this.dayColumnWidth,
    required this.rowHeight,
    required this.gap,
  });

  final int dayCount;
  final int periodCount;
  final double dayColumnWidth;
  final double rowHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (var periodIndex = 0; periodIndex < periodCount; periodIndex++) ...[
          Row(
            children: [
              for (var dayIndex = 0; dayIndex < dayCount; dayIndex++) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.32,
                    ),
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: SizedBox(width: dayColumnWidth, height: rowHeight),
                ),
                if (dayIndex < dayCount - 1) SizedBox(width: gap),
              ],
            ],
          ),
          if (periodIndex < periodCount - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class _PositionedScheduledCourse extends StatelessWidget {
  const _PositionedScheduledCourse({
    required this.course,
    required this.dayColumnWidth,
    required this.rowHeight,
    required this.gap,
    required this.onTap,
  });

  final ScheduledCourse course;
  final double dayColumnWidth;
  final double rowHeight;
  final double gap;
  final ValueChanged<ScheduledCourse> onTap;

  @override
  Widget build(BuildContext context) {
    final top = course.startPeriodIndex * (rowHeight + gap);
    final left = course.dayIndex * (dayColumnWidth + gap);
    final height = course.length * rowHeight + (course.length - 1) * gap;

    return Positioned(
      top: top,
      left: left,
      width: dayColumnWidth,
      height: height,
      child: CalendarItem(
        courseName: course.name,
        length: course.length,
        onTap: () => onTap(course),
      ),
    );
  }
}

class _ScheduledCourseDetailsSheet extends StatelessWidget {
  const _ScheduledCourseDetailsSheet({required this.course});

  final ScheduledCourse course;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _CourseSelectionPageContentState._maxSheetWidth,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                _CourseDetailRow(
                  icon: Icons.category_outlined,
                  label: '類型',
                  value: course.category,
                ),
                _CourseDetailRow(
                  icon: Icons.place_outlined,
                  label: '地點',
                  value: course.location,
                ),
                _CourseDetailRow(
                  icon: Icons.schedule,
                  label: '節數',
                  value: '${course.length} 節',
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchPanel extends StatefulWidget {
  const _SearchPanel({
    required this.controller,
    required this.useAdvancedFilterDialog,
  });

  static const _creditOptions = <int>[0, 1, 2, 3, 4, 6];

  final CourseSelectionController controller;
  final bool useAdvancedFilterDialog;

  @override
  State<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<_SearchPanel> {
  late final TextEditingController _keywordController;

  CourseSelectionController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(text: controller.keyword);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SearchBar(
              controller: _keywordController,
              constraints: const BoxConstraints(minHeight: 56.0),
              hintText: '搜尋課程名稱',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  tooltip: '搜尋',
                  onPressed: controller.isLoading ? null : _applyTextFilters,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
              enabled: !controller.isLoading,
              onSubmitted: (_) => _applyTextFilters(),
            ),
          ),
          if (controller.hasActiveFilter) ...[
            const SizedBox(height: 10.0),
            _ActiveFilterSummary(
              controller: controller,
              onClear: _clearFilters,
            ),
          ],
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : () => _showAdvancedFilterSheet(context),
              icon: const Icon(Icons.tune),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('進階查詢'),
                  if (_advancedFilterCount > 0) ...[
                    const SizedBox(width: 8.0),
                    Badge(
                      label: Text(_advancedFilterCount.toString()),
                      backgroundColor: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (controller.error != null && controller.courses.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Text('更新失敗，保留目前結果', style: TextStyle(color: colorScheme.error)),
          ],
        ],
      ),
    );
  }

  void _applyTextFilters() {
    unawaited(controller.search(keyword: _keywordController.text));
  }

  void _clearFilters() {
    _keywordController.clear();
    unawaited(controller.clearFilters());
  }

  int get _advancedFilterCount {
    return [
      controller.classNo.isNotEmpty,
      controller.serialNo.isNotEmpty,
      controller.departmentName.isNotEmpty,
      controller.collegeName.isNotEmpty,
      controller.instructor.isNotEmpty,
      controller.courseType != null,
      controller.credits.isNotEmpty,
      controller.hasVacancy != null,
      controller.classTimes.isNotEmpty,
    ].where((isActive) => isActive).length;
  }

  void _showAdvancedFilterSheet(BuildContext context) {
    if (widget.useAdvancedFilterDialog) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) {
            return Dialog(
              clipBehavior: Clip.antiAlias,
              insetPadding: const EdgeInsets.all(32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _CourseSelectionPageContentState
                      ._maxAdvancedFilterDialogWidth,
                ),
                child: SizedBox(
                  height: (MediaQuery.sizeOf(context).height - 64.0).clamp(
                    680.0,
                    760.0,
                  ),
                  child: _AdvancedFilterSheet(
                    controller: controller,
                    useDialogLayout: true,
                  ),
                ),
              ),
            );
          },
        ),
      );
      return;
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          return _AdvancedFilterSheet(controller: controller);
        },
      ),
    );
  }
}

class _AdvancedFilterSheet extends StatefulWidget {
  const _AdvancedFilterSheet({
    required this.controller,
    this.useDialogLayout = false,
  });

  final CourseSelectionController controller;
  final bool useDialogLayout;

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  static const _classTimeWeekDays = ['一', '二', '三', '四', '五', '六', '日'];
  static const _classTimePeriods = [
    '1',
    '2',
    '3',
    '4',
    'Z',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
  ];

  late final TextEditingController _classNoController;
  late final TextEditingController _serialNoController;
  late final TextEditingController _departmentNameController;
  late final TextEditingController _collegeNameController;
  late final TextEditingController _instructorController;
  late String? _courseType;
  late final Set<int> _credits;
  late bool? _hasVacancy;
  late Set<String> _classTimes;
  int _visibleClassTimeDayCount = 5;

  CourseSelectionController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _classNoController = TextEditingController(text: controller.classNo);
    _serialNoController = TextEditingController(text: controller.serialNo);
    _departmentNameController = TextEditingController(
      text: controller.departmentName,
    );
    _collegeNameController = TextEditingController(
      text: controller.collegeName,
    );
    _instructorController = TextEditingController(text: controller.instructor);
    _courseType = controller.courseType;
    _credits = controller.credits.toSet();
    _hasVacancy = controller.hasVacancy;
    _classTimes = controller.classTimes.toSet();
  }

  @override
  void dispose() {
    _classNoController.dispose();
    _serialNoController.dispose();
    _departmentNameController.dispose();
    _collegeNameController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final contentPadding = widget.useDialogLayout
        ? const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 28.0)
        : EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0 + bottomInset);
    final content = widget.useDialogLayout
        ? _buildDialogContent(context, contentPadding)
        : _buildSheetContent(context, contentPadding);

    if (widget.useDialogLayout) {
      return SafeArea(child: content);
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _CourseSelectionPageContentState._maxSheetWidth,
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _buildDialogContent(
    BuildContext context,
    EdgeInsetsGeometry contentPadding,
  ) {
    return Padding(
      padding: contentPadding,
      child: Column(
        children: [
          _AdvancedFilterHeader(onClose: () => Navigator.of(context).pop()),
          const SizedBox(height: 16.0),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SingleChildScrollView(child: _buildFilters())),
                const VerticalDivider(width: 32.0),
                Expanded(child: _buildInlineClassTimePicker(context)),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          _AdvancedFilterActions(
            isLoading: controller.isLoading,
            onApply: _applyFilters,
            onClear: _clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    EdgeInsetsGeometry contentPadding,
  ) {
    return SingleChildScrollView(
      padding: contentPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdvancedFilterHeader(onClose: () => Navigator.of(context).pop()),
          const SizedBox(height: 12.0),
          _buildFilters(),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isLoading ? null : _showClassTimePicker,
              icon: const Icon(Icons.schedule_outlined),
              label: Text(_classTimeButtonText),
            ),
          ),
          const SizedBox(height: 12.0),
          _AdvancedFilterActions(
            isLoading: controller.isLoading,
            onApply: _applyFilters,
            onClear: _clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdvancedSearchFields(
          enabled: !controller.isLoading,
          classNoController: _classNoController,
          serialNoController: _serialNoController,
          departmentNameController: _departmentNameController,
          collegeNameController: _collegeNameController,
          instructorController: _instructorController,
          onSubmitted: _applyFilters,
        ),
        const SizedBox(height: 12.0),
        Text('課程類型', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8.0),
        _DraftCourseTypeSegmentedControl(
          value: _courseType,
          enabled: !controller.isLoading,
          onChanged: (value) => setState(() => _courseType = value),
        ),
        const SizedBox(height: 12.0),
        Text('學分', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8.0),
        _DraftCreditFilterGrid(
          selectedCredits: _credits,
          enabled: !controller.isLoading,
          onToggle: _toggleCredit,
        ),
        const SizedBox(height: 12.0),
        Text('名額', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8.0),
        _DraftVacancySegmentedControl(
          value: _hasVacancy,
          enabled: !controller.isLoading,
          onChanged: (value) => setState(() => _hasVacancy = value),
        ),
      ],
    );
  }

  Widget _buildInlineClassTimePicker(BuildContext context) {
    final visibleDays = _classTimeWeekDays
        .take(_visibleClassTimeDayCount)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '上課時段',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            TextButton(
              onPressed: _classTimes.isEmpty
                  ? null
                  : () => setState(() => _classTimes.clear()),
              child: const Text('清除'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 5, label: Text('平日')),
            ButtonSegment(value: 7, label: Text('全週')),
          ],
          selected: {_visibleClassTimeDayCount},
          onSelectionChanged: (values) {
            setState(() => _visibleClassTimeDayCount = values.single);
          },
        ),
        const SizedBox(height: 12.0),
        Expanded(
          child: _ClassTimeGrid(
            days: visibleDays,
            periods: _classTimePeriods,
            selectedValues: _classTimes,
            enabled: !controller.isLoading,
            onToggle: _toggleClassTime,
          ),
        ),
      ],
    );
  }

  String get _classTimeButtonText {
    final count = _classTimes.length;
    if (count == 0) return '選擇上課時段';
    return '已選 $count 個時段';
  }

  void _toggleCredit(int credit) {
    setState(() {
      if (!_credits.add(credit)) {
        _credits.remove(credit);
      }
    });
  }

  void _toggleClassTime(String value) {
    setState(() {
      if (!_classTimes.add(value)) {
        _classTimes.remove(value);
      }
    });
  }

  Future<void> _showClassTimePicker() async {
    final nextValues = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return _DraftClassTimePickerSheet(classTimes: _classTimes);
      },
    );
    if (nextValues == null) return;
    setState(() => _classTimes = nextValues);
  }

  void _clearFilters() {
    _classNoController.clear();
    _serialNoController.clear();
    _departmentNameController.clear();
    _collegeNameController.clear();
    _instructorController.clear();
    setState(() {
      _courseType = null;
      _credits.clear();
      _hasVacancy = null;
      _classTimes = {};
    });
  }

  void _applyFilters() {
    unawaited(
      controller
          .applyFilters(
            classNo: _classNoController.text,
            serialNo: _serialNoController.text,
            departmentName: _departmentNameController.text,
            collegeName: _collegeNameController.text,
            instructor: _instructorController.text,
            courseType: _courseType,
            credits: _credits,
            hasVacancy: _hasVacancy,
            classTimes: _classTimes,
          )
          .then((_) {
            if (mounted) Navigator.of(context).pop();
          }),
    );
  }
}

class _ActiveFilterSummary extends StatelessWidget {
  const _ActiveFilterSummary({required this.controller, required this.onClear});

  final CourseSelectionController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final chips = _filterLabels()
        .map(
          (label) =>
              Chip(label: Text(label), visualDensity: VisualDensity.compact),
        )
        .toList(growable: false);

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...chips,
        ActionChip(
          avatar: const Icon(Icons.close, size: 18.0),
          label: const Text('清除全部'),
          onPressed: controller.isLoading ? null : onClear,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  List<String> _filterLabels() {
    final labels = <String>[];
    if (controller.keyword.isNotEmpty) {
      labels.add('關鍵字：${controller.keyword}');
    }
    if (controller.classNo.isNotEmpty) {
      labels.add('課號：${controller.classNo}');
    }
    if (controller.serialNo.isNotEmpty) {
      labels.add('流水號：${controller.serialNo}');
    }
    if (controller.departmentName.isNotEmpty) {
      labels.add('系所：${controller.departmentName}');
    }
    if (controller.collegeName.isNotEmpty) {
      labels.add('學院：${controller.collegeName}');
    }
    if (controller.instructor.isNotEmpty) {
      labels.add('授課教師：${controller.instructor}');
    }
    if (controller.courseType != null) {
      labels.add('類型：${_courseTypeText(controller.courseType)}');
    }
    if (controller.credits.isNotEmpty) {
      labels.add('學分：${controller.credits.join('、')}');
    }
    if (controller.hasVacancy != null) {
      labels.add(controller.hasVacancy == true ? '尚有名額' : '已額滿');
    }
    if (controller.classTimes.isNotEmpty) {
      labels.add('時段：${controller.classTimes.length} 個');
    }
    return labels;
  }

  String _courseTypeText(String? courseType) {
    return switch (courseType) {
      'REQUIRED' => '必修',
      'ELECTIVE' => '選修',
      final value? => value,
      _ => '全部',
    };
  }
}

class _AdvancedFilterHeader extends StatelessWidget {
  const _AdvancedFilterHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('進階查詢', style: Theme.of(context).textTheme.titleLarge),
        ),
        IconButton(
          tooltip: '關閉',
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _AdvancedFilterActions extends StatelessWidget {
  const _AdvancedFilterActions({
    required this.isLoading,
    required this.onApply,
    required this.onClear,
  });

  final bool isLoading;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isLoading ? null : onApply,
            icon: const Icon(Icons.tune),
            label: const Text('套用查詢'),
          ),
        ),
        const SizedBox(width: 8.0),
        OutlinedButton.icon(
          onPressed: isLoading ? null : onClear,
          icon: const Icon(Icons.close),
          label: const Text('清除'),
        ),
      ],
    );
  }
}

class _AdvancedSearchFields extends StatelessWidget {
  const _AdvancedSearchFields({
    required this.enabled,
    required this.classNoController,
    required this.serialNoController,
    required this.departmentNameController,
    required this.collegeNameController,
    required this.instructorController,
    required this.onSubmitted,
  });

  final bool enabled;
  final TextEditingController classNoController;
  final TextEditingController serialNoController;
  final TextEditingController departmentNameController;
  final TextEditingController collegeNameController;
  final TextEditingController instructorController;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560.0;
        final fields = [
          _SearchTextField(
            controller: classNoController,
            enabled: enabled,
            label: '課號',
            hintText: 'LN1001-A',
            icon: Icons.tag_outlined,
            onSubmitted: onSubmitted,
          ),
          _SearchTextField(
            controller: serialNoController,
            enabled: enabled,
            label: '流水號',
            hintText: '12345',
            icon: Icons.confirmation_number_outlined,
            onSubmitted: onSubmitted,
          ),
          _SearchTextField(
            controller: departmentNameController,
            enabled: enabled,
            label: '系所',
            hintText: '資訊工程學系',
            icon: Icons.apartment_outlined,
            onSubmitted: onSubmitted,
          ),
          _SearchTextField(
            controller: collegeNameController,
            enabled: enabled,
            label: '學院',
            hintText: '文學院',
            icon: Icons.account_balance_outlined,
            onSubmitted: onSubmitted,
          ),
          _SearchTextField(
            controller: instructorController,
            enabled: enabled,
            label: '授課教師',
            hintText: '王小明',
            icon: Icons.person_search_outlined,
            onSubmitted: onSubmitted,
          ),
        ];

        if (!isWide) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                fields[index],
                if (index < fields.length - 1) const SizedBox(height: 8.0),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var index = 0; index < fields.length; index += 2) ...[
              Row(
                children: [
                  Expanded(child: fields[index]),
                  const SizedBox(width: 8.0),
                  if (index + 1 < fields.length)
                    Expanded(child: fields[index + 1])
                  else
                    const Spacer(),
                ],
              ),
              if (index < fields.length - 2) const SizedBox(height: 8.0),
            ],
          ],
        );
      },
    );
  }
}

class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String hintText;
  final IconData icon;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: (_) => onSubmitted(),
    );
  }
}

class _DraftCreditFilterGrid extends StatelessWidget {
  const _DraftCreditFilterGrid({
    required this.selectedCredits,
    required this.enabled,
    required this.onToggle,
  });

  final Set<int> selectedCredits;
  final bool enabled;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columnCount = 3;
        const spacing = 8.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final credit in _SearchPanel._creditOptions)
              SizedBox(
                width: itemWidth,
                child: FilterChip(
                  showCheckmark: false,
                  label: Center(child: Text('$credit 學分')),
                  selected: selectedCredits.contains(credit),
                  onSelected: enabled ? (_) => onToggle(credit) : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DraftClassTimePickerSheet extends StatefulWidget {
  const _DraftClassTimePickerSheet({required this.classTimes});

  final Set<String> classTimes;

  @override
  State<_DraftClassTimePickerSheet> createState() =>
      _DraftClassTimePickerSheetState();
}

class _DraftClassTimePickerSheetState
    extends State<_DraftClassTimePickerSheet> {
  static const _weekDays = ['一', '二', '三', '四', '五', '六', '日'];
  static const _periods = [
    '1',
    '2',
    '3',
    '4',
    'Z',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
  ];

  int _visibleDayCount = 5;
  late final Set<String> _selectedClassTimes;

  @override
  void initState() {
    super.initState();
    _selectedClassTimes = widget.classTimes.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final visibleDays = _weekDays.take(_visibleDayCount).toList();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _CourseSelectionPageContentState._maxSheetWidth,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0 + bottomInset),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '上課時段',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: _selectedClassTimes.isEmpty
                            ? null
                            : () {
                                setState(_selectedClassTimes.clear);
                              },
                        child: const Text('清除'),
                      ),
                      TextButton(
                        onPressed: () => _applySelection(context),
                        child: const Text('套用'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 5, label: Text('平日')),
                      ButtonSegment(value: 7, label: Text('全週')),
                    ],
                    selected: {_visibleDayCount},
                    onSelectionChanged: (values) {
                      setState(() => _visibleDayCount = values.single);
                    },
                  ),
                  const SizedBox(height: 12.0),
                  Expanded(
                    child: _ClassTimeGrid(
                      days: visibleDays,
                      periods: _periods,
                      selectedValues: _selectedClassTimes,
                      enabled: true,
                      onToggle: _toggleClassTime,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleClassTime(String value) {
    setState(() {
      if (!_selectedClassTimes.add(value)) {
        _selectedClassTimes.remove(value);
      }
    });
  }

  void _applySelection(BuildContext context) {
    Navigator.of(context).pop(_selectedClassTimes);
  }
}

class _ClassTimeGrid extends StatelessWidget {
  const _ClassTimeGrid({
    required this.days,
    required this.periods,
    required this.selectedValues,
    required this.enabled,
    required this.onToggle,
  });

  final List<String> days;
  final List<String> periods;
  final Set<String> selectedValues;
  final bool enabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const rowHeaderWidth = 34.0;
        const cellGap = 4.0;
        final totalGapWidth = cellGap * (days.length - 1);
        final availableWidth =
            constraints.maxWidth - rowHeaderWidth - totalGapWidth;
        final cellWidth = (availableWidth / days.length).clamp(0.0, 54.0);
        const cellHeight = 30.0;

        return SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: rowHeaderWidth),
                    for (
                      var dayIndex = 0;
                      dayIndex < days.length;
                      dayIndex++
                    ) ...[
                      SizedBox(
                        width: cellWidth,
                        height: 24.0,
                        child: Center(
                          child: Text(
                            days[dayIndex],
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                      if (dayIndex < days.length - 1)
                        const SizedBox(width: cellGap),
                    ],
                  ],
                ),
                const SizedBox(height: 4.0),
                for (
                  var periodIndex = 0;
                  periodIndex < periods.length;
                  periodIndex++
                ) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: rowHeaderWidth,
                        height: cellHeight,
                        child: Center(
                          child: Text(
                            periods[periodIndex],
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                      for (
                        var dayIndex = 0;
                        dayIndex < days.length;
                        dayIndex++
                      ) ...[
                        _ClassTimeGridCell(
                          dayLabel: days[dayIndex],
                          period: periods[periodIndex],
                          value: '${dayIndex + 1}-${periods[periodIndex]}',
                          width: cellWidth,
                          height: cellHeight,
                          selected: selectedValues.contains(
                            '${dayIndex + 1}-${periods[periodIndex]}',
                          ),
                          enabled: enabled,
                          onToggle: onToggle,
                          colorScheme: colorScheme,
                        ),
                        if (dayIndex < days.length - 1)
                          const SizedBox(width: cellGap),
                      ],
                    ],
                  ),
                  if (periodIndex < periods.length - 1)
                    const SizedBox(height: cellGap),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClassTimeGridCell extends StatelessWidget {
  const _ClassTimeGridCell({
    required this.dayLabel,
    required this.period,
    required this.value,
    required this.width,
    required this.height,
    required this.selected,
    required this.enabled,
    required this.onToggle,
    required this.colorScheme,
  });

  final String dayLabel;
  final String period;
  final String value;
  final double width;
  final double height;
  final bool selected;
  final bool enabled;
  final ValueChanged<String> onToggle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$dayLabel $period',
      child: SizedBox(
        width: width,
        height: height,
        child: InkWell(
          onTap: enabled ? () => onToggle(value) : null,
          borderRadius: BorderRadius.circular(8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
              border: Border.all(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftCourseTypeSegmentedControl extends StatelessWidget {
  const _DraftCourseTypeSegmentedControl({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / 3;
        return SegmentedButton<_CourseTypeFilter>(
          showSelectedIcon: false,
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(segmentWidth, 44.0)),
          ),
          segments: const [
            ButtonSegment(value: _CourseTypeFilter.all, label: Text('全部')),
            ButtonSegment(value: _CourseTypeFilter.required, label: Text('必修')),
            ButtonSegment(value: _CourseTypeFilter.elective, label: Text('選修')),
          ],
          selected: {_selectedFilter},
          onSelectionChanged: enabled
              ? (values) => onChanged(_toCourseType(values.single))
              : null,
        );
      },
    );
  }

  _CourseTypeFilter get _selectedFilter {
    return switch (value) {
      'REQUIRED' => _CourseTypeFilter.required,
      'ELECTIVE' => _CourseTypeFilter.elective,
      _ => _CourseTypeFilter.all,
    };
  }

  String? _toCourseType(_CourseTypeFilter filter) {
    return switch (filter) {
      _CourseTypeFilter.all => null,
      _CourseTypeFilter.required => 'REQUIRED',
      _CourseTypeFilter.elective => 'ELECTIVE',
    };
  }
}

class _DraftVacancySegmentedControl extends StatelessWidget {
  const _DraftVacancySegmentedControl({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool? value;
  final bool enabled;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / 3;
        return SegmentedButton<_VacancyFilter>(
          showSelectedIcon: false,
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(segmentWidth, 44.0)),
          ),
          segments: const [
            ButtonSegment(value: _VacancyFilter.all, label: Text('全部')),
            ButtonSegment(value: _VacancyFilter.available, label: Text('尚有名額')),
            ButtonSegment(value: _VacancyFilter.full, label: Text('已額滿')),
          ],
          selected: {_selectedFilter},
          onSelectionChanged: enabled
              ? (values) => onChanged(_toHasVacancy(values.single))
              : null,
        );
      },
    );
  }

  _VacancyFilter get _selectedFilter {
    return switch (value) {
      true => _VacancyFilter.available,
      false => _VacancyFilter.full,
      null => _VacancyFilter.all,
    };
  }

  bool? _toHasVacancy(_VacancyFilter filter) {
    return switch (filter) {
      _VacancyFilter.all => null,
      _VacancyFilter.available => true,
      _VacancyFilter.full => false,
    };
  }
}

class _LocalCourseFilterSheet extends StatefulWidget {
  const _LocalCourseFilterSheet({
    required this.onlyShowTimetableCompatibleCourses,
    required this.onlyShowSelectedCourses,
    required this.useDialogLayout,
  });

  final bool onlyShowTimetableCompatibleCourses;
  final bool onlyShowSelectedCourses;
  final bool useDialogLayout;

  @override
  State<_LocalCourseFilterSheet> createState() =>
      _LocalCourseFilterSheetState();
}

class _LocalCourseFilterSheetState extends State<_LocalCourseFilterSheet> {
  late bool _onlyShowTimetableCompatibleCourses;
  late bool _onlyShowSelectedCourses;

  @override
  void initState() {
    super.initState();
    _onlyShowTimetableCompatibleCourses =
        widget.onlyShowTimetableCompatibleCourses;
    _onlyShowSelectedCourses = widget.onlyShowSelectedCourses;
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: widget.useDialogLayout
          ? const EdgeInsets.all(24.0)
          : const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('檢視選項', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8.0),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.event_available_outlined),
            title: const Text('只顯示本頁可加入課表的課程'),
            value: _onlyShowTimetableCompatibleCourses,
            onChanged: (value) {
              setState(() => _onlyShowTimetableCompatibleCourses = value);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.checklist_outlined),
            title: const Text('只顯示已加入課表的課程'),
            value: _onlyShowSelectedCourses,
            onChanged: (value) {
              setState(() => _onlyShowSelectedCourses = value);
            },
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(
                _LocalCourseFilterState(
                  onlyShowTimetableCompatibleCourses:
                      _onlyShowTimetableCompatibleCourses,
                  onlyShowSelectedCourses: _onlyShowSelectedCourses,
                ),
              ),
              child: const Text('完成'),
            ),
          ),
        ],
      ),
    );

    if (widget.useDialogLayout) {
      return content;
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _CourseSelectionPageContentState._maxSheetWidth,
          ),
          child: content,
        ),
      ),
    );
  }
}

class _LocalCourseFilterState {
  const _LocalCourseFilterState({
    required this.onlyShowTimetableCompatibleCourses,
    required this.onlyShowSelectedCourses,
  });

  final bool onlyShowTimetableCompatibleCourses;
  final bool onlyShowSelectedCourses;
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({
    required this.controller,
    required this.displayedCourseCount,
    required this.localFilterActive,
    required this.localFilterTotalCount,
    required this.onFilterPressed,
  });

  final CourseSelectionController controller;
  final int displayedCourseCount;
  final bool localFilterActive;
  final int localFilterTotalCount;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lastUpdated = controller.lastUpdated;
    final subtitle = lastUpdated == null
        ? '資料更新時間未提供'
        : '更新於 ${_formatDateTime(lastUpdated)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isLoading && controller.courses.isNotEmpty
                      ? '更新中...'
                      : _courseCountText(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (controller.isLoading && controller.courses.isNotEmpty)
            const SizedBox(
              width: 18.0,
              height: 18.0,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            )
          else
            IconButton(
              tooltip: '檢視選項',
              isSelected: localFilterActive,
              onPressed: onFilterPressed,
              icon: const Icon(Icons.filter_list),
              selectedIcon: const Icon(Icons.filter_list),
            ),
        ],
      ),
    );
  }

  String _courseCountText() {
    if (localFilterActive) {
      return '顯示 $displayedCourseCount / $localFilterTotalCount 門課程';
    }
    return '顯示 ${controller.courses.length} / ${controller.totalCount} 門課程';
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _CourseListTile extends StatelessWidget {
  const _CourseListTile({
    required this.course,
    required this.isSelected,
    required this.canSyncToTimetable,
    required this.alignActionsToBottom,
    required this.onTap,
    required this.onSyncToggle,
  });

  final CourseItem course;
  final bool isSelected;
  final bool canSyncToTimetable;
  final bool alignActionsToBottom;
  final VoidCallback onTap;
  final VoidCallback onSyncToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actionRow = Row(
      children: [
        Icon(Icons.schedule, size: 16.0, color: colorScheme.primary),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(
            course.classTimeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8.0),
        _CourseSyncButton(
          isSelected: isSelected,
          canSyncToTimetable: canSyncToTimetable,
          onPressed: onSyncToggle,
        ),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.brightness == Brightness.light
          ? Colors.white
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _CourseTypeBadge(label: course.courseTypeText),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                '${course.classNo} · ${course.creditText} 學分 · ${course.teacherText}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: [
                  _CourseMetaChip(
                    icon: Icons.account_balance_outlined,
                    label: course.openingUnitText,
                  ),
                  _CourseMetaChip(
                    icon: Icons.groups_outlined,
                    label: course.enrollmentText,
                  ),
                  if (course.showsPasswordCardHint)
                    _CourseMetaChip(
                      icon: Icons.vpn_key_outlined,
                      label: course.passwordCardText,
                    ),
                ],
              ),
              if (alignActionsToBottom) const Spacer(),
              const SizedBox(height: 8.0),
              actionRow,
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseSyncButton extends StatelessWidget {
  const _CourseSyncButton({
    required this.isSelected,
    required this.canSyncToTimetable,
    required this.onPressed,
  });

  final bool isSelected;
  final bool canSyncToTimetable;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check),
        label: const Text('已加入'),
      );
    }

    return FilledButton.icon(
      onPressed: canSyncToTimetable ? onPressed : null,
      icon: const Icon(Icons.add),
      label: Text(canSyncToTimetable ? '加入' : '無時段'),
    );
  }
}

class _CourseTypeBadge extends StatelessWidget {
  const _CourseTypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.0,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CourseMetaChip extends StatelessWidget {
  const _CourseMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.0, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4.0),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseDetailsSheet extends StatelessWidget {
  const _CourseDetailsSheet({required this.course});

  final CourseItem course;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _CourseDetailsContent(
        course: course,
        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
      ),
    );
  }
}

class _CourseDetailsDialog extends StatelessWidget {
  const _CourseDetailsDialog({
    required this.course,
    required this.supplementalDetail,
  });

  final CourseItem course;
  final Future<CourseSupplementalDetail?> supplementalDetail;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(32.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth:
              _CourseSelectionPageContentState._maxCourseDetailsDialogWidth,
        ),
        child: SizedBox(
          key: const ValueKey('course-details-dialog-body'),
          height: _CourseSelectionPageContentState._courseDetailsDialogHeight,
          child: FutureBuilder<CourseSupplementalDetail?>(
            future: supplementalDetail,
            builder: (context, snapshot) {
              return _CourseDetailsContent(
                course: course,
                supplementalDetail: snapshot.data,
                isLoadingSupplementalDetail:
                    snapshot.connectionState != ConnectionState.done,
                padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
                showCloseButton: true,
                useHorizontalActions: true,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CourseDetailsContent extends StatelessWidget {
  const _CourseDetailsContent({
    required this.course,
    required this.padding,
    this.supplementalDetail,
    this.isLoadingSupplementalDetail = false,
    this.showCloseButton = false,
    this.useHorizontalActions = false,
  });

  final CourseItem course;
  final EdgeInsetsGeometry padding;
  final CourseSupplementalDetail? supplementalDetail;
  final bool isLoadingSupplementalDetail;
  final bool showCloseButton;
  final bool useHorizontalActions;

  @override
  Widget build(BuildContext context) {
    final showSupplementalDetail =
        useHorizontalActions &&
        (isLoadingSupplementalDetail || supplementalDetail?.hasContent == true);

    final content = Column(
      mainAxisSize: useHorizontalActions ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: _SelectableCourseText(
                      course.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: _CourseTypeBadge(label: course.courseTypeText),
                  ),
                ],
              ),
            ),
            if (showCloseButton) ...[
              const SizedBox(width: 8.0),
              IconButton(
                tooltip: '關閉',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16.0),
        if (showSupplementalDetail && useHorizontalActions)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('course-primary-details-scroll'),
                    child: _CoursePrimaryDetails(
                      course: course,
                      supplementalDetail: supplementalDetail,
                    ),
                  ),
                ),
                const VerticalDivider(width: 32.0),
                Expanded(
                  child: isLoadingSupplementalDetail
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: _CourseSupplementalDetails(
                            detail: supplementalDetail!,
                          ),
                        ),
                ),
              ],
            ),
          )
        else if (showSupplementalDetail)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CoursePrimaryDetails(
                  course: course,
                  supplementalDetail: supplementalDetail,
                ),
              ),
              const VerticalDivider(width: 32.0),
              Expanded(
                child: _CourseSupplementalDetails(detail: supplementalDetail!),
              ),
            ],
          )
        else if (useHorizontalActions)
          Expanded(child: _CoursePrimaryDetails(course: course))
        else
          _CoursePrimaryDetails(course: course),
        const SizedBox(height: 12.0),
        if (useHorizontalActions)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
            ],
          )
        else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openCourseDetailUrl(context),
              child: const Text('課程詳細資訊'),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
          ),
        ],
      ],
    );

    if (useHorizontalActions) {
      return Padding(padding: padding, child: content);
    }

    return SingleChildScrollView(padding: padding, child: content);
  }

  void _openCourseDetailUrl(BuildContext context) {
    final navigator = Navigator.of(context);
    final targetUrl = Uri.parse(course.detailUrlWithParams);

    navigator.pop();
    unawaited(
      navigator.push(
        AppRoutes.portalWebView(title: course.title, targetUrl: targetUrl),
      ),
    );
  }
}

class _CoursePrimaryDetails extends StatelessWidget {
  const _CoursePrimaryDetails({required this.course, this.supplementalDetail});

  final CourseItem course;
  final CourseSupplementalDetail? supplementalDetail;

  @override
  Widget build(BuildContext context) {
    final distributionConditionText =
        supplementalDetail?.distributionConditionText ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CourseDetailRow(
          icon: Icons.confirmation_number_outlined,
          label: '課號',
          value: '${course.classNo} / ${course.serialNo}',
        ),
        _CourseDetailRow(
          icon: Icons.person_outline,
          label: '授課教師',
          value: course.teacherText,
        ),
        _CourseDetailRow(
          icon: Icons.schedule,
          label: '上課時間',
          value: course.classTimeText,
        ),
        _CourseDetailRow(
          icon: Icons.school_outlined,
          label: '學分',
          value: '${course.creditText} 學分',
        ),
        _CourseDetailRow(
          icon: Icons.groups_outlined,
          label: '選課人數',
          value: course.enrollmentText,
        ),
        _CourseDetailRow(
          icon: Icons.vpn_key_outlined,
          label: '密碼卡',
          value: course.passwordCardText,
        ),
        if (course.departmentName != null || course.collegeName != null)
          _CourseDetailRow(
            icon: Icons.account_balance_outlined,
            label: '開課單位',
            value: [
              if (course.collegeName != null) course.collegeName,
              if (course.departmentName != null) course.departmentName,
            ].join(' / '),
          ),
        if (distributionConditionText.isNotEmpty)
          _CourseDetailRow(
            icon: Icons.rule_outlined,
            label: '分發條件',
            value: distributionConditionText,
          ),
      ],
    );
  }
}

class _CourseSupplementalDetails extends StatelessWidget {
  const _CourseSupplementalDetails({required this.detail});

  final CourseSupplementalDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CourseSupplementalSection(title: '課程目標', value: detail.objectives),
        _CourseSupplementalSection(title: '課程內容', value: detail.content),
        _CourseSupplementalSection(title: '指定用書', value: detail.books),
        _CourseSupplementalSection(title: '教學方式', value: detail.teachingMethod),
        _CourseSupplementalSection(title: '評分方式', value: detail.gradingPolicy),
      ],
    );
  }
}

class _CourseSupplementalSection extends StatelessWidget {
  const _CourseSupplementalSection({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SelectableCourseText(
            title,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4.0),
          _SelectableCourseText(
            value,
            style: TextStyle(height: 1.45, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _SelectableCourseText extends StatelessWidget {
  const _SelectableCourseText(this.data, {this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return SelectableText(data, style: style);
    }
    return Text(data, style: style);
  }
}

class _CourseDetailRow extends StatelessWidget {
  const _CourseDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0, color: colorScheme.primary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SelectableCourseText(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2.0),
                _SelectableCourseText(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40.0),
          const SizedBox(height: 12.0),
          const Text('課程資料載入失敗'),
          const SizedBox(height: 12.0),
          FilledButton(onPressed: onRetry, child: const Text('重新載入')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('沒有符合條件的課程'));
  }
}
