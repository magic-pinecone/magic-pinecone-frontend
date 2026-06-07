import 'package:flutter/material.dart';
import 'package:prototype/features/course_selection/presentation/course_selection_layout.dart';

class DraftClassTimePickerSheet extends StatefulWidget {
  const DraftClassTimePickerSheet({super.key, required this.classTimes});

  final Set<String> classTimes;

  @override
  State<DraftClassTimePickerSheet> createState() =>
      _DraftClassTimePickerSheetState();
}

class _DraftClassTimePickerSheetState extends State<DraftClassTimePickerSheet> {
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
            maxWidth: CourseSelectionLayout.maxSheetWidth,
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
                    child: ClassTimeGrid(
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

class ClassTimeGrid extends StatelessWidget {
  const ClassTimeGrid({
    super.key,
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
