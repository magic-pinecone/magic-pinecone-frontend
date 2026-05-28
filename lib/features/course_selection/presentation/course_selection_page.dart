import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/core/navigation/app_routes.dart';
import 'package:prototype/core/widgets/owned_change_notifier_builder.dart';
import 'package:prototype/features/course_selection/data/course_schedule_repository.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:prototype/features/course_selection/presentation/widgets/calendar_item.dart';

class CourseSelectionPage extends StatelessWidget {
  const CourseSelectionPage({super.key, this.controller});

  final CourseSelectionController? controller;

  @override
  Widget build(BuildContext context) {
    return OwnedChangeNotifierBuilder<CourseSelectionController>(
      notifier: controller,
      create: (context) =>
          AppScope.of(context).createCourseSelectionController(),
      onReady: (controller) => unawaited(controller.load()),
      builder: (context, controller) =>
          _CourseSelectionPageContent(controller: controller),
    );
  }
}

enum _CourseSelectionView { search, timetable, helper }

class _CourseSelectionPageContent extends StatefulWidget {
  const _CourseSelectionPageContent({required this.controller});

  final CourseSelectionController controller;

  @override
  State<_CourseSelectionPageContent> createState() =>
      _CourseSelectionPageContentState();
}

class _CourseSelectionPageContentState
    extends State<_CourseSelectionPageContent> {
  static const _horizontalPadding = 16.0;

  final CourseScheduleRepository _scheduleRepository =
      const StaticCourseScheduleRepository();
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
  int _messageSequence = 0;

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
        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return IconButton(
                  tooltip: '切換課程工具',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                );
              },
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
          drawer: NavigationDrawer(
            selectedIndex: _selectedView.index,
            onDestinationSelected: (index) {
              Navigator.of(context).pop();
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
          body: switch (_selectedView) {
            _CourseSelectionView.search => RefreshIndicator(
              onRefresh: controller.search,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _SearchPanel(controller: controller),
                  ),
                  SliverToBoxAdapter(
                    child: _ResultSummary(controller: controller),
                  ),
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
                  else if (controller.courses.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        _horizontalPadding,
                        4.0,
                        _horizontalPadding,
                        20.0,
                      ),
                      sliver: SliverList.separated(
                        itemCount: controller.courses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8.0),
                        itemBuilder: (context, index) {
                          final course = controller.courses[index];
                          return _CourseListTile(
                            course: course,
                            isSelected: _isCourseSelected(course),
                            canSyncToTimetable: _canSyncToTimetable(course),
                            onTap: () => _showCourseDetails(context, course),
                            onSyncToggle: () => _toggleCourseSelection(course),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            _CourseSelectionView.timetable => _CourseTimetableView(
              snapshot: _syncedScheduleSnapshot(),
            ),
            _CourseSelectionView.helper => _CourseHelperChatView(
              chatController: _chatController,
              onMessageSend: _sendHelperMessage,
            ),
          },
        );
      },
    );
  }

  void _showCourseDetails(BuildContext context, CourseItem course) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => _CourseDetailsSheet(course: course),
      ),
    );
  }

  bool _isCourseSelected(CourseItem course) {
    return _selectedCourses.containsKey(course.serialNo);
  }

  bool _canSyncToTimetable(CourseItem course) {
    final baseSchedule = _scheduleRepository.loadSchedule();
    return _courseToScheduledCourses(course, baseSchedule.periods).isNotEmpty;
  }

  void _toggleCourseSelection(CourseItem course) {
    setState(() {
      if (_selectedCourses.containsKey(course.serialNo)) {
        _selectedCourses.remove(course.serialNo);
      } else {
        _selectedCourses[course.serialNo] = course;
      }
    });
  }

  CourseScheduleSnapshot _syncedScheduleSnapshot() {
    final baseSchedule = _scheduleRepository.loadSchedule();
    final syncedCourses = _selectedCourses.values.expand(
      (course) => _courseToScheduledCourses(course, baseSchedule.periods),
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

class _CourseTimeSlot {
  const _CourseTimeSlot({required this.dayIndex, required this.periodIndex});

  final int dayIndex;
  final int periodIndex;
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
  const _CourseTimetableView({required this.snapshot});

  static const _periodColumnWidth = 34.0;
  static const _maxDayColumnWidth = 118.0;
  static const _rowHeight = 48.0;
  static const _gridGap = 6.0;
  static const _headerHeight = 32.0;

  final CourseScheduleSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalGapWidth = _gridGap * (snapshot.weekDays.length - 1);
          final availableWidth =
              constraints.maxWidth - _periodColumnWidth - totalGapWidth - 24.0;
          final dayColumnWidth = (availableWidth / snapshot.weekDays.length)
              .clamp(0.0, _maxDayColumnWidth);
          final totalWidth =
              _periodColumnWidth +
              snapshot.weekDays.length * dayColumnWidth +
              totalGapWidth;
          final gridHeight =
              snapshot.periods.length * _rowHeight +
              (snapshot.periods.length - 1) * _gridGap;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 20.0),
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
  });

  final ScheduledCourse course;
  final double dayColumnWidth;
  final double rowHeight;
  final double gap;

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
        onTap: () => _showScheduledCourse(context, course),
      ),
    );
  }

  void _showScheduledCourse(BuildContext context, ScheduledCourse course) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => _ScheduledCourseDetailsSheet(course: course),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({required this.controller});

  static const _creditOptions = <int>[0, 1, 2, 3, 4, 6];

  final CourseSelectionController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            hintText: '搜尋課名或關鍵字',
            leading: const Icon(Icons.search),
            enabled: !controller.isLoading,
            onSubmitted: (value) =>
                unawaited(controller.search(keyword: value)),
          ),
          const SizedBox(height: 12.0),
          Text('課程類型', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _CourseTypeChip(
                label: '全部',
                selected: controller.courseType == null,
                onSelected: () => unawaited(controller.setCourseType(null)),
              ),
              _CourseTypeChip(
                label: '必修',
                selected: controller.courseType == 'REQUIRED',
                onSelected: () =>
                    unawaited(controller.setCourseType('REQUIRED')),
              ),
              _CourseTypeChip(
                label: '選修',
                selected: controller.courseType == 'ELECTIVE',
                onSelected: () =>
                    unawaited(controller.setCourseType('ELECTIVE')),
              ),
              if (controller.hasActiveFilter)
                ActionChip(
                  avatar: const Icon(Icons.close, size: 18.0),
                  label: const Text('清除'),
                  onPressed: controller.isLoading
                      ? null
                      : () => unawaited(controller.clearFilters()),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text('學分', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (final credit in _creditOptions)
                FilterChip(
                  label: Text('$credit 學分'),
                  selected: controller.hasCredit(credit),
                  onSelected: controller.isLoading
                      ? null
                      : (_) => unawaited(controller.toggleCredit(credit)),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text('進階選項', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              FilterChip(
                label: const Text('僅顯示尚有名額的課程'),
                selected: controller.hasVacancy == true,
                showCheckmark: false,
                onSelected: controller.isLoading
                    ? null
                    : (selected) => unawaited(
                        controller.setHasVacancy(selected ? true : null),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : () => _showClassTimePicker(context),
              icon: const Icon(Icons.schedule_outlined),
              label: Text(_classTimeButtonText),
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

  String get _classTimeButtonText {
    final count = controller.classTimes.length;
    if (count == 0) return '選擇上課時段';
    return '已選 $count 個時段';
  }

  void _showClassTimePicker(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          return _ClassTimePickerSheet(controller: controller);
        },
      ),
    );
  }
}

class _ClassTimePickerSheet extends StatefulWidget {
  const _ClassTimePickerSheet({required this.controller});

  final CourseSelectionController controller;

  @override
  State<_ClassTimePickerSheet> createState() => _ClassTimePickerSheetState();
}

class _ClassTimePickerSheetState extends State<_ClassTimePickerSheet> {
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

  CourseSelectionController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final visibleDays = _weekDays.take(_visibleDayCount).toList();

    return SafeArea(
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
                  ListenableBuilder(
                    listenable: controller,
                    child: const Text('清除'),
                    builder: (context, child) {
                      return TextButton(
                        onPressed: controller.classTimes.isEmpty
                            ? null
                            : () => unawaited(controller.clearClassTimes()),
                        child: child!,
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('完成'),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              SegmentedButton<int>(
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
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    return _ClassTimeGrid(
                      days: visibleDays,
                      periods: _periods,
                      controller: controller,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassTimeGrid extends StatelessWidget {
  const _ClassTimeGrid({
    required this.days,
    required this.periods,
    required this.controller,
  });

  final List<String> days;
  final List<String> periods;
  final CourseSelectionController controller;

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
                          controller: controller,
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
    required this.controller,
    required this.colorScheme,
  });

  final String dayLabel;
  final String period;
  final String value;
  final double width;
  final double height;
  final CourseSelectionController controller;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final selected = controller.classTimes.contains(value);

    return Tooltip(
      message: '$dayLabel $period',
      child: SizedBox(
        width: width,
        height: height,
        child: InkWell(
          onTap: controller.isLoading
              ? null
              : () => unawaited(controller.toggleClassTime(value)),
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

class _CourseTypeChip extends StatelessWidget {
  const _CourseTypeChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.controller});

  final CourseSelectionController controller;

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
                      : '共 ${controller.totalCount} 門課程',
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
            ),
        ],
      ),
    );
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
    required this.onTap,
    required this.onSyncToggle,
  });

  final CourseItem course;
  final bool isSelected;
  final bool canSyncToTimetable;
  final VoidCallback onTap;
  final VoidCallback onSyncToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Chip(
                    label: Text(course.courseTypeText),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                '${course.classNo} · ${course.creditText} 學分 · ${course.teacherText}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8.0),
              Row(
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
              ),
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

class _CourseDetailsSheet extends StatelessWidget {
  const _CourseDetailsSheet({required this.course});

  final CourseItem course;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Chip(label: Text(course.courseTypeText)),
              ],
            ),
            const SizedBox(height: 16.0),
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
            if (course.departmentId != null || course.collegeId != null)
              _CourseDetailRow(
                icon: Icons.account_balance_outlined,
                label: '開課單位',
                value: [
                  if (course.collegeId != null) course.collegeId,
                  if (course.departmentId != null) course.departmentId,
                ].join(' / '),
              ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openCourseDetailUrl(context),
                child: const Text('課程詳細資訊'),
              ),
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
    );
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
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
