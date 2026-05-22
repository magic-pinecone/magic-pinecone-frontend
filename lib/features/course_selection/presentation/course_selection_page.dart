import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/core/widgets/owned_change_notifier_builder.dart';
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
      builder: (context, controller) =>
          _CourseSelectionPageContent(controller: controller),
    );
  }
}

class _CourseSelectionPageContent extends StatelessWidget {
  const _CourseSelectionPageContent({required this.controller});

  static const double _headerHeight = 36.0;
  static const double _periodWidth = 40.0;

  final CourseSelectionController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final days = controller.visibleDays;
        final periods = controller.periods;

        return Scaffold(
          appBar: _buildAppBar(context),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final totalHeight = constraints.maxHeight;

              final dayWidth = (totalWidth - _periodWidth) / days.length;
              final rowHeight =
                  (totalHeight - _headerHeight - 1) / periods.length;

              return Column(
                children: [
                  _buildHeader(days, dayWidth),
                  const Divider(height: 1),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildTimetable(
                          context,
                          days,
                          periods,
                          dayWidth,
                          rowHeight,
                        ),
                        ..._buildCourseCards(
                          context,
                          days.length,
                          dayWidth,
                          rowHeight,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: const Text('課表', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '週末',
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            ),
            Switch(
              value: controller.showWeekends,
              onChanged: controller.setShowWeekends,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(List<String> days, double dayWidth) {
    return Row(
      children: [
        const SizedBox(width: _periodWidth),
        ...days.map(
          (day) => SizedBox(
            width: dayWidth,
            height: _headerHeight,
            child: Center(
              child: Text(
                day,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimetable(
    BuildContext context,
    List<String> days,
    List<String> periods,
    double dayWidth,
    double rowHeight,
  ) {
    return Column(
      children: List.generate(
        periods.length,
        (index) =>
            _buildPeriodRow(context, index, days, periods, dayWidth, rowHeight),
      ),
    );
  }

  List<Widget> _buildCourseCards(
    BuildContext context,
    int visibleDayCount,
    double dayWidth,
    double rowHeight,
  ) {
    return controller.courses
        .where((course) => course.dayIndex < visibleDayCount)
        .map((course) {
          return Positioned(
            top: course.startPeriodIndex * rowHeight,
            left: _periodWidth + (course.dayIndex * dayWidth),
            width: dayWidth,
            height: course.length * rowHeight,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: CalendarItem(
                courseName: course.name,
                length: course.length,
                onTap: () => _showCourseDetails(context, course),
              ),
            ),
          );
        })
        .toList();
  }

  Widget _buildPeriodRow(
    BuildContext context,
    int index,
    List<String> days,
    List<String> periods,
    double dayWidth,
    double rowHeight,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEven = index.isEven;

    return Container(
      color: isEven ? colorScheme.surface : colorScheme.surfaceContainerHighest,
      height: rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: _periodWidth,
            child: Center(
              child: Text(
                periods[index],
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          ...List.generate(
            days.length,
            (col) => _buildDayCell(context, col, index, dayWidth, rowHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    int col,
    int periodIndex,
    double dayWidth,
    double rowHeight,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () =>
          _showSearchModal(context, day: col, periodIndex: periodIndex),
      child: Container(
        width: dayWidth,
        height: rowHeight,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchModal(
    BuildContext context, {
    required int day,
    required int periodIndex,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final period = controller.periods[periodIndex];
    final days = controller.visibleDays;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '新增課程 (週${days[day]} 第$period 節)',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                hintText: '搜尋課程',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      title: Text('計算機概論'),
                      subtitle: Text('通識中心'),
                      trailing: Icon(Icons.add_circle_outline),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('英文閱讀'),
                      subtitle: Text('語言中心'),
                      trailing: Icon(Icons.add_circle_outline),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseDetails(BuildContext context, ScheduledCourse course) {
    final dayLabel = controller.visibleDays[course.dayIndex];
    final startPeriod = controller.periods[course.startPeriodIndex];
    final endPeriod =
        controller.periods[course.startPeriodIndex + course.length - 1];
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(label: Text(course.category)),
              ],
            ),
            const SizedBox(height: 16.0),
            _CourseDetailRow(
              icon: Icons.schedule,
              label: '上課時間',
              value: '週$dayLabel 第 $startPeriod-$endPeriod 節',
            ),
            const SizedBox(height: 12.0),
            _CourseDetailRow(
              icon: Icons.location_on_outlined,
              label: '上課地點',
              value: course.location,
            ),
            const SizedBox(height: 12.0),
            _CourseDetailRow(
              icon: Icons.info_outline,
              label: '課程分類',
              value: course.category,
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                ),
                child: const Text('關閉'),
              ),
            ),
          ],
        ),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
