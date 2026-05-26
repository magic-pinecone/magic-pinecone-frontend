import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/core/navigation/app_routes.dart';
import 'package:prototype/core/widgets/owned_change_notifier_builder.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';

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

class _CourseSelectionPageContent extends StatelessWidget {
  const _CourseSelectionPageContent({required this.controller});

  static const _horizontalPadding = 16.0;

  final CourseSelectionController controller;

  @override
  Widget build(BuildContext context) {
    // 1. 讓 ListenableBuilder 回到最外層包裹整個 Scaffold，徹底解除 Sliver 閃退危機
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
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
          body: RefreshIndicator(
            onRefresh: controller.search,
            child: CustomScrollView(
              slivers: [
                // 2. 內部回歸乾淨的 Sliver 結構，不再需要一堆雜亂的局部 Builder 和 Adapter
                SliverToBoxAdapter(child: _SearchPanel(controller: controller)),
                SliverToBoxAdapter(
                  child: _ResultSummary(controller: controller),
                ),
                if (controller.isLoading && controller.courses.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.error != null && controller.courses.isEmpty)
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
                          onTap: () => _showCourseDetails(context, course),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
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
}
class _SearchPanel extends StatelessWidget {
  const _SearchPanel({required this.controller});

  static const _creditOptions = <int>[1, 2, 3, 4];

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
                    builder: (context, _) {
                      return TextButton(
                        onPressed: controller.classTimes.isEmpty
                            ? null
                            : () => unawaited(controller.clearClassTimes()),
                        child: const Text('清除'),
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
  const _CourseListTile({required this.course, required this.onTap});

  final CourseItem course;
  final VoidCallback onTap;

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
                  Expanded(child: Text(course.classTimeText)),
                ],
              ),
            ],
          ),
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
