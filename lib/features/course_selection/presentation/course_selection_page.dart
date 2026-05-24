import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_scope.dart';
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
          if (controller.error != null && controller.courses.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Text('更新失敗，保留目前結果', style: TextStyle(color: colorScheme.error)),
          ],
        ],
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
