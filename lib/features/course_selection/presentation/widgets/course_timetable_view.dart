import 'package:flutter/material.dart';
import 'package:prototype/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/course_selection_layout.dart';
import 'package:prototype/features/course_selection/presentation/widgets/calendar_item.dart';
import 'package:prototype/features/course_selection/presentation/widgets/course_detail_row.dart';

class CourseTimetableView extends StatelessWidget {
  const CourseTimetableView({
    super.key,
    required this.snapshot,
    required this.totalCredits,
    required this.conflictSlotCount,
    required this.showSaveAction,
    required this.showPreviewHint,
    required this.onSavePressed,
    required this.onDiscardPressed,
    required this.onSharePressed,
    required this.onCourseTap,
  });

  static const _periodColumnWidth = 34.0;
  static const _maxDayColumnWidth = 118.0;
  static const _minRowHeight = 30.0;
  static const _maxRowHeight = 48.0;
  static const _gridGap = 6.0;
  static const _headerHeight = 32.0;
  static const _topPadding = 58.0;
  static const _bottomPadding = 12.0;

  final CourseScheduleSnapshot snapshot;
  final int totalCredits;
  final int conflictSlotCount;
  final bool showSaveAction;
  final bool showPreviewHint;
  final VoidCallback onSavePressed;
  final VoidCallback onDiscardPressed;
  final VoidCallback? onSharePressed;
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
                final totalPeriodGapHeight =
                    (snapshot.periods.length - 1) * _gridGap;
                final availableGridHeight =
                    constraints.maxHeight -
                    _topPadding -
                    _bottomPadding -
                    _headerHeight -
                    _gridGap;
                final rowHeight =
                    ((availableGridHeight - totalPeriodGapHeight) /
                            snapshot.periods.length)
                        .clamp(_minRowHeight, _maxRowHeight);
                final gridHeight =
                    snapshot.periods.length * rowHeight + totalPeriodGapHeight;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    12.0,
                    _topPadding,
                    12.0,
                    _bottomPadding,
                  ),
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
                                rowHeight: rowHeight,
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
                                      rowHeight: rowHeight,
                                      gap: _gridGap,
                                    ),
                                    for (final course in snapshot.courses)
                                      _PositionedScheduledCourse(
                                        course: course,
                                        dayColumnWidth: dayColumnWidth,
                                        rowHeight: rowHeight,
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
                onDiscardPressed: onDiscardPressed,
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
    required this.onDiscardPressed,
    required this.onSharePressed,
  });

  final int totalCredits;
  final int conflictSlotCount;
  final bool showSaveAction;
  final bool showPreviewHint;
  final VoidCallback onSavePressed;
  final VoidCallback onDiscardPressed;
  final VoidCallback? onSharePressed;

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
                label: '還原',
                onPressed: onDiscardPressed,
                foregroundColor: colorScheme.error,
              ),
            if (showSaveAction)
              _TimetableToolbarTextAction(
                label: '儲存',
                onPressed: onSavePressed,
                foregroundColor: colorScheme.primary,
              ),
            Tooltip(
              message: onSharePressed == null ? '請先儲存後再分享' : '複製分享連結',
              child: _TimetableToolbarTextAction(
                label: '分享',
                onPressed: onSharePressed,
                foregroundColor: colorScheme.onSurface,
              ),
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
  final VoidCallback? onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = onPressed == null
        ? Theme.of(context).disabledColor
        : foregroundColor;

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
              color: effectiveForegroundColor,
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

class ScheduledCourseDetailsSheet extends StatelessWidget {
  const ScheduledCourseDetailsSheet({super.key, required this.course});

  final ScheduledCourse course;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CourseSelectionLayout.maxSheetWidth,
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
                CourseDetailRow(
                  icon: Icons.category_outlined,
                  label: '類型',
                  value: course.category,
                ),
                CourseDetailRow(
                  icon: Icons.place_outlined,
                  label: '地點',
                  value: course.location,
                ),
                CourseDetailRow(
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
