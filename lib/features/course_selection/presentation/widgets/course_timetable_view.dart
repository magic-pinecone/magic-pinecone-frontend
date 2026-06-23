import 'package:flutter/material.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_layout.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/calendar_item.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_detail_row.dart';

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
  final Future<void> Function() onSavePressed;
  final Future<void> Function() onDiscardPressed;
  final Future<void> Function()? onSharePressed;
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
              child: _TimetableActionPill(
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

enum _TimetableActionPillFeedbackAction { save }

class _TimetableActionPill extends StatefulWidget {
  const _TimetableActionPill({
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
  final Future<void> Function() onSavePressed;
  final Future<void> Function() onDiscardPressed;
  final Future<void> Function()? onSharePressed;

  @override
  State<_TimetableActionPill> createState() => _TimetableActionPillState();
}

class _TimetableActionPillState extends State<_TimetableActionPill> {
  static const _successDuration = Duration(milliseconds: 1400);

  _TimetableActionPillFeedbackAction? _visibleFeedbackAction;
  _TimetableActionPillFeedbackAction? _successFeedbackAction;
  var _feedbackVersion = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasConflict = widget.conflictSlotCount > 0;
    final showSaveFeedback =
        _visibleFeedbackAction == _TimetableActionPillFeedbackAction.save;
    final showSavedFeedback =
        _successFeedbackAction == _TimetableActionPillFeedbackAction.save;

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
            _TimetableActionPillItem(
              icon: Icons.school_outlined,
              label: '${widget.totalCredits} 學分',
              foregroundColor: colorScheme.onSurface,
            ),
            _TimetableActionPillItem(
              icon: hasConflict
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              label: hasConflict ? '衝堂 ${widget.conflictSlotCount} 節' : '無衝堂',
              foregroundColor: hasConflict
                  ? colorScheme.error
                  : colorScheme.primary,
            ),
            if (widget.showPreviewHint)
              Tooltip(
                message: '預覽中，儲存後才會覆蓋本機課表。',
                child: _TimetableActionPillItem(
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
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              alignment: Alignment.centerLeft,
              child: showSaveFeedback
                  ? _TimetableActionPillFeedbackTextAction(
                      label: showSavedFeedback ? '已儲存' : '儲存',
                      showSuccessIcon: showSavedFeedback,
                      onPressed: null,
                      foregroundColor: colorScheme.primary,
                    )
                  : widget.showSaveAction
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TimetableActionPillFeedbackTextAction(
                          label: '還原',
                          showSuccessIcon: false,
                          onPressed:
                              widget.showSaveAction &&
                                  _visibleFeedbackAction == null
                              ? widget.onDiscardPressed
                              : null,
                          foregroundColor: colorScheme.error,
                        ),
                        _TimetableActionPillFeedbackTextAction(
                          label: '儲存',
                          showSuccessIcon: false,
                          onPressed:
                              widget.showSaveAction &&
                                  _visibleFeedbackAction == null
                              ? () =>
                                    _runSaveFeedbackAction(widget.onSavePressed)
                              : null,
                          foregroundColor: colorScheme.primary,
                        ),
                        Tooltip(
                          message: widget.onSharePressed == null
                              ? '請先儲存後再分享'
                              : '複製分享連結',
                          child: _TimetableShareAction(
                            onPressed: widget.onSharePressed,
                            foregroundColor: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    )
                  : Tooltip(
                      message: widget.onSharePressed == null
                          ? '請先儲存後再分享'
                          : '複製分享連結',
                      child: _TimetableShareAction(
                        onPressed: widget.onSharePressed,
                        foregroundColor: colorScheme.onSurface,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runSaveFeedbackAction(Future<void> Function() callback) async {
    final version = _feedbackVersion + 1;
    setState(() {
      _feedbackVersion = version;
      _visibleFeedbackAction = _TimetableActionPillFeedbackAction.save;
      _successFeedbackAction = null;
    });

    await callback();
    if (!mounted || _feedbackVersion != version) return;

    setState(() {
      _successFeedbackAction = _TimetableActionPillFeedbackAction.save;
    });

    await Future<void>.delayed(_successDuration);
    if (!mounted || _feedbackVersion != version) return;

    setState(() {
      _visibleFeedbackAction = null;
      _successFeedbackAction = null;
    });
  }
}

class _TimetableShareAction extends StatefulWidget {
  const _TimetableShareAction({
    required this.onPressed,
    required this.foregroundColor,
  });

  final Future<void> Function()? onPressed;
  final Color foregroundColor;

  @override
  State<_TimetableShareAction> createState() => _TimetableShareActionState();
}

class _TimetableShareActionState extends State<_TimetableShareAction> {
  static const _successDuration = Duration(milliseconds: 1400);

  var _showSuccess = false;
  var _feedbackVersion = 0;

  @override
  void didUpdateWidget(_TimetableShareAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null && _showSuccess) {
      _feedbackVersion += 1;
      _showSuccess = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveForegroundColor = widget.onPressed == null
        ? theme.disabledColor
        : _showSuccess
        ? colorScheme.primary
        : widget.foregroundColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: widget.onPressed == null ? null : _share,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            alignment: Alignment.centerLeft,
            child: _TimetableShareActionLabel(
              label: _showSuccess ? '已複製' : '分享',
              showSuccessIcon: _showSuccess,
              foregroundColor: effectiveForegroundColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _share() async {
    final onPressed = widget.onPressed;
    if (onPressed == null) return;

    await onPressed();
    if (!mounted) return;

    final version = _feedbackVersion + 1;
    setState(() {
      _feedbackVersion = version;
      _showSuccess = true;
    });

    await Future<void>.delayed(_successDuration);
    if (!mounted || _feedbackVersion != version) return;

    setState(() {
      _showSuccess = false;
    });
  }
}

class _TimetableShareActionLabel extends StatelessWidget {
  const _TimetableShareActionLabel({
    required this.label,
    required this.showSuccessIcon,
    required this.foregroundColor,
  });

  final String label;
  final bool showSuccessIcon;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w700,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textStyle),
        if (showSuccessIcon) ...[
          const SizedBox(width: 4.0),
          Icon(Icons.check_circle_rounded, size: 16.0, color: foregroundColor),
        ],
      ],
    );
  }
}

class _TimetableActionPillFeedbackTextAction extends StatelessWidget {
  const _TimetableActionPillFeedbackTextAction({
    required this.label,
    required this.showSuccessIcon,
    required this.onPressed,
    required this.foregroundColor,
  });

  final String label;
  final bool showSuccessIcon;
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
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(label),
              child: _TimetableShareActionLabel(
                label: label,
                showSuccessIcon: showSuccessIcon,
                foregroundColor: showSuccessIcon
                    ? foregroundColor
                    : effectiveForegroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimetableActionPillItem extends StatelessWidget {
  const _TimetableActionPillItem({
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
