import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prototype/features/course_selection/presentation/course_selection_layout.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:prototype/features/course_selection/presentation/widgets/course_advanced_filter_sheet.dart';

class CourseSearchPanel extends StatefulWidget {
  const CourseSearchPanel({
    super.key,
    required this.controller,
    required this.useAdvancedFilterDialog,
  });

  final CourseSelectionController controller;
  final bool useAdvancedFilterDialog;

  @override
  State<CourseSearchPanel> createState() => _CourseSearchPanelState();
}

class _CourseSearchPanelState extends State<CourseSearchPanel> {
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
                  maxWidth: CourseSelectionLayout.maxAdvancedFilterDialogWidth,
                ),
                child: SizedBox(
                  height: (MediaQuery.sizeOf(context).height - 64.0).clamp(
                    680.0,
                    760.0,
                  ),
                  child: CourseAdvancedFilterSheet(
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
          return CourseAdvancedFilterSheet(controller: controller);
        },
      ),
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
