import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_layout.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_advanced_filter_sheet.dart';

class CourseSearchPanel extends ConsumerStatefulWidget {
  const CourseSearchPanel({super.key, required this.useAdvancedFilterDialog});

  final bool useAdvancedFilterDialog;

  @override
  ConsumerState<CourseSearchPanel> createState() => _CourseSearchPanelState();
}

class _CourseSearchPanelState extends ConsumerState<CourseSearchPanel> {
  late final TextEditingController _keywordController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(courseSelectionControllerProvider);
    _keywordController = TextEditingController(text: state.keyword);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseSelectionControllerProvider);
    final notifier = ref.read(courseSelectionControllerProvider.notifier);
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
                  onPressed: state.isLoading
                      ? null
                      : () => _applyTextFilters(notifier),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
              enabled: !state.isLoading,
              onSubmitted: (_) => _applyTextFilters(notifier),
            ),
          ),
          if (state.hasActiveFilter) ...[
            const SizedBox(height: 10.0),
            _ActiveFilterSummary(onClear: () => _clearFilters(notifier)),
          ],
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => _showAdvancedFilterSheet(context),
              icon: const Icon(Icons.tune),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('進階查詢'),
                  if (_advancedFilterCount(state) > 0) ...[
                    const SizedBox(width: 8.0),
                    Badge(
                      label: Text(_advancedFilterCount(state).toString()),
                      backgroundColor: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (state.error != null && state.courses.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Text('更新失敗，保留目前結果', style: TextStyle(color: colorScheme.error)),
          ],
        ],
      ),
    );
  }

  void _applyTextFilters(CourseSelectionController notifier) {
    unawaited(notifier.search(keyword: _keywordController.text));
  }

  void _clearFilters(CourseSelectionController notifier) {
    _keywordController.clear();
    unawaited(notifier.clearFilters());
  }

  int _advancedFilterCount(CourseSelectionState state) {
    return [
      state.classNo.isNotEmpty,
      state.serialNo.isNotEmpty,
      state.departmentName.isNotEmpty,
      state.collegeName.isNotEmpty,
      state.instructor.isNotEmpty,
      state.courseType != null,
      state.credits.isNotEmpty,
      state.hasVacancy != null,
      state.classTimes.isNotEmpty,
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
                  child: const CourseAdvancedFilterSheet(useDialogLayout: true),
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
          return const CourseAdvancedFilterSheet();
        },
      ),
    );
  }
}

class _ActiveFilterSummary extends ConsumerWidget {
  const _ActiveFilterSummary({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseSelectionControllerProvider);
    final chips = _filterLabels(state)
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
          onPressed: state.isLoading ? null : onClear,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  List<String> _filterLabels(CourseSelectionState state) {
    final labels = <String>[];
    if (state.keyword.isNotEmpty) {
      labels.add('關鍵字：${state.keyword}');
    }
    if (state.classNo.isNotEmpty) {
      labels.add('課號：${state.classNo}');
    }
    if (state.serialNo.isNotEmpty) {
      labels.add('流水號：${state.serialNo}');
    }
    if (state.departmentName.isNotEmpty) {
      labels.add('系所：${state.departmentName}');
    }
    if (state.collegeName.isNotEmpty) {
      labels.add('學院：${state.collegeName}');
    }
    if (state.instructor.isNotEmpty) {
      labels.add('授課教師：${state.instructor}');
    }
    if (state.courseType != null) {
      labels.add('類型：${_courseTypeText(state.courseType)}');
    }
    if (state.credits.isNotEmpty) {
      labels.add('學分：${state.credits.join('、')}');
    }
    if (state.hasVacancy != null) {
      labels.add(state.hasVacancy == true ? '尚有名額' : '已額滿');
    }
    if (state.classTimes.isNotEmpty) {
      labels.add('時段：${state.classTimes.length} 個');
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
