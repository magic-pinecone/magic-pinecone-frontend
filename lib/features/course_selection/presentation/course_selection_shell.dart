import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/features/course_selection/course_selection_providers.dart';
import 'package:magic_pinecone/features/course_selection/data/data_sources/course_selection_storage.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_supplemental_detail_repository.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_layout.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_plan_controller.dart';
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
  _CourseSelectionView _selectedView = _CourseSelectionView.search;
  bool _didRestoreSelectedCourses = false;

  late CourseSelectionState _state;
  late CourseSelectionController _notifier;
  late CoursePlanState _planState;
  late CoursePlanController _planController;
  late SettingsState _settingsState;
  late CourseSelectionStorage _courseSelectionStorage;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(courseSelectionControllerProvider.notifier).load());
    });
  }

  @override
  Widget build(BuildContext context) {
    _state = ref.watch(courseSelectionControllerProvider);
    _notifier = ref.read(courseSelectionControllerProvider.notifier);
    _planState = ref.watch(coursePlanControllerProvider);
    _planController = ref.read(coursePlanControllerProvider.notifier);
    _settingsState = ref.watch(settingsViewModelProvider);
    _courseSelectionStorage =
        widget.courseSelectionStorage ??
        ref.watch(courseSelectionStorageProvider);
    final supplementalDetailRepository = ref.watch(
      courseSupplementalDetailRepositoryProvider,
    );

    if (_state.isLoading && _state.courses.isEmpty) {
      _planController.clearCourseCaches();
    }
    if (!_state.isLoading && !_didRestoreSelectedCourses) {
      _didRestoreSelectedCourses = true;
      unawaited(_restoreSelectedCourses());
    }
    final displayedCourses = _planController.displayedCourses(_state.courses);
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
    final snapshot = _planController.visibleScheduleSnapshot(
      omitWeekends: _settingsState.omitWeekendsOnTimetable,
    );
    return CourseTimetableView(
      snapshot: snapshot,
      totalCredits: _planState.selectedTotalCredits,
      conflictSlotCount: _planController.conflictSlotCount(snapshot),
      showSaveAction: _planState.canSaveCourseSelection && useDesktopDialog,
      showPreviewHint: _planState.isPreviewingSharedCourses,
      onSavePressed: () => _saveCourseSelection(showSnackBar: false),
      onDiscardPressed: _discardUnsavedCourseSelection,
      onSharePressed: _planState.hasUnsavedCourseSelection
          ? null
          : _shareSelectedCourses,
      onCourseTap: (course) => _showTimetableCourseDetails(
        context,
        course,
        supplementalDetailRepository,
        useDesktopDialog: useDesktopDialog,
      ),
    );
  }

  Widget? _buildMobileCourseSelectionActions() {
    if (!_planState.canSaveCourseSelection ||
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
      isCourseSelected: _planController.isCourseSelected,
      canSyncToTimetable: _planController.canSyncToTimetable,
      onCourseTap: (course) => _showCourseDetails(
        context,
        course,
        supplementalDetailRepository,
        useDesktopDialog: useDesktopCourseDetails,
      ),
      onCourseSyncToggle: _planController.toggleCourseSelection,
      onLocalFilterPressed: () =>
          _showLocalFilterSheet(context, useDialog: useAdvancedFilterDialog),
      localFilterActive:
          _planState.onlyShowTimetableCompatibleCourses ||
          _planState.onlyShowSelectedCourses,
      localFilterTotalCount: _planController.localFilterTotalCount(
        _state.courses.length,
      ),
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
            toggleCourseSelection: _planController.toggleCourseSelection,
            isCourseSelected: _planController.isCourseSelected,
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
          toggleCourseSelection: _planController.toggleCourseSelection,
          isCourseSelected: _planController.isCourseSelected,
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
    final course = serialNo == null
        ? null
        : _planState.selectedCourses[serialNo];
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
        onlyShowTimetableCompatibleCourses:
            _planState.onlyShowTimetableCompatibleCourses,
        onlyShowSelectedCourses: _planState.onlyShowSelectedCourses,
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
    _planController.setLocalFilters(
      onlyShowTimetableCompatibleCourses:
          nextValue.onlyShowTimetableCompatibleCourses,
      onlyShowSelectedCourses: nextValue.onlyShowSelectedCourses,
    );
  }

  Future<void> _shareSelectedCourses() async {
    final shareUrl = _planController.selectedCourseShareUrl(baseUri: Uri.base);
    await Clipboard.setData(ClipboardData(text: shareUrl.toString()));
  }

  Future<void> _restoreSelectedCourses() async {
    final result = await _planController.restoreInitialSelection(
      storage: _courseSelectionStorage,
      initialShareCode: widget.initialShareCode,
      baseUri: Uri.base,
    );
    if (!mounted) return;
    if (result.restored && result.preview) {
      setState(() {
        _selectedView = _CourseSelectionView.timetable;
      });
    }
  }

  Future<void> _discardUnsavedCourseSelection() async {
    await _planController.discardUnsavedCourseSelection(
      storage: _courseSelectionStorage,
    );
  }

  Future<void> _saveCourseSelection({bool showSnackBar = true}) async {
    await _planController.saveCourseSelection(storage: _courseSelectionStorage);
    if (!mounted || !showSnackBar) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已儲存課表')));
  }
}
