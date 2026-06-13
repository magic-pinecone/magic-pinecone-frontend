import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_layout.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_class_time_picker.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_filter_segmented_controls.dart';

const _creditOptions = <int>[0, 1, 2, 3, 4, 6];

class CourseAdvancedFilterSheet extends ConsumerStatefulWidget {
  const CourseAdvancedFilterSheet({super.key, this.useDialogLayout = false});

  final bool useDialogLayout;

  @override
  ConsumerState<CourseAdvancedFilterSheet> createState() =>
      _CourseAdvancedFilterSheetState();
}

class _CourseAdvancedFilterSheetState
    extends ConsumerState<CourseAdvancedFilterSheet> {
  static const _classTimeWeekDays = ['一', '二', '三', '四', '五', '六', '日'];
  static const _classTimePeriods = [
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

  late final TextEditingController _classNoController;
  late final TextEditingController _serialNoController;
  late final TextEditingController _departmentNameController;
  late final TextEditingController _collegeNameController;
  late final TextEditingController _instructorController;
  late String? _courseType;
  late final Set<int> _credits;
  late bool? _hasVacancy;
  late Set<String> _classTimes;
  int _visibleClassTimeDayCount = 5;

  CourseSelectionState get _state =>
      ref.read(courseSelectionControllerProvider);
  CourseSelectionController get _notifier =>
      ref.read(courseSelectionControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    final state = ref.read(courseSelectionControllerProvider);
    _classNoController = TextEditingController(text: state.classNo);
    _serialNoController = TextEditingController(text: state.serialNo);
    _departmentNameController = TextEditingController(
      text: state.departmentName,
    );
    _collegeNameController = TextEditingController(text: state.collegeName);
    _instructorController = TextEditingController(text: state.instructor);
    _courseType = state.courseType;
    _credits = state.credits.toSet();
    _hasVacancy = state.hasVacancy;
    _classTimes = state.classTimes.toSet();
  }

  @override
  void dispose() {
    _classNoController.dispose();
    _serialNoController.dispose();
    _departmentNameController.dispose();
    _collegeNameController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(courseSelectionControllerProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final contentPadding = widget.useDialogLayout
        ? const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 28.0)
        : EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0 + bottomInset);
    final content = widget.useDialogLayout
        ? _buildDialogContent(context, contentPadding)
        : _buildSheetContent(context, contentPadding);

    if (widget.useDialogLayout) {
      return SafeArea(child: content);
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CourseSelectionLayout.maxSheetWidth,
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _buildDialogContent(
    BuildContext context,
    EdgeInsetsGeometry contentPadding,
  ) {
    return Padding(
      padding: contentPadding,
      child: Column(
        children: [
          _AdvancedFilterHeader(onClose: () => Navigator.of(context).pop()),
          const SizedBox(height: 16.0),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SingleChildScrollView(child: _buildFilters())),
                const VerticalDivider(width: 32.0),
                Expanded(child: _buildInlineClassTimePicker(context)),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          _AdvancedFilterActions(
            isLoading: _state.isLoading,
            onApply: _applyFilters,
            onClear: _clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    EdgeInsetsGeometry contentPadding,
  ) {
    return SingleChildScrollView(
      padding: contentPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdvancedFilterHeader(onClose: () => Navigator.of(context).pop()),
          const SizedBox(height: 12.0),
          _buildFilters(),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _state.isLoading ? null : _showClassTimePicker,
              icon: const Icon(Icons.schedule_outlined),
              label: Text(_classTimeButtonText),
            ),
          ),
          const SizedBox(height: 12.0),
          _AdvancedFilterActions(
            isLoading: _state.isLoading,
            onApply: _applyFilters,
            onClear: _clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdvancedSearchFields(
          enabled: !_state.isLoading,
          classNoController: _classNoController,
          serialNoController: _serialNoController,
          departmentNameController: _departmentNameController,
          collegeNameController: _collegeNameController,
          instructorController: _instructorController,
          onSubmitted: _applyFilters,
        ),
        const SizedBox(height: 12.0),
        Text('課程類型', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8.0),
        DraftCourseTypeSegmentedControl(
          value: _courseType,
          enabled: !_state.isLoading,
          onChanged: (value) => setState(() => _courseType = value),
        ),
        const SizedBox(height: 12.0),
        Text('學分', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8.0),
        _DraftCreditFilterGrid(
          selectedCredits: _credits,
          enabled: !_state.isLoading,
          onToggle: _toggleCredit,
        ),
        const SizedBox(height: 12.0),
        Text('名額', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8.0),
        DraftVacancySegmentedControl(
          value: _hasVacancy,
          enabled: !_state.isLoading,
          onChanged: (value) => setState(() => _hasVacancy = value),
        ),
      ],
    );
  }

  Widget _buildInlineClassTimePicker(BuildContext context) {
    final visibleDays = _classTimeWeekDays
        .take(_visibleClassTimeDayCount)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '上課時段',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            TextButton(
              onPressed: _classTimes.isEmpty
                  ? null
                  : () => setState(() => _classTimes.clear()),
              child: const Text('清除'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 5, label: Text('平日')),
            ButtonSegment(value: 7, label: Text('全週')),
          ],
          selected: {_visibleClassTimeDayCount},
          onSelectionChanged: (values) {
            setState(() => _visibleClassTimeDayCount = values.single);
          },
        ),
        const SizedBox(height: 12.0),
        Expanded(
          child: ClassTimeGrid(
            days: visibleDays,
            periods: _classTimePeriods,
            selectedValues: _classTimes,
            enabled: !_state.isLoading,
            onToggle: _toggleClassTime,
          ),
        ),
      ],
    );
  }

  String get _classTimeButtonText {
    final count = _classTimes.length;
    if (count == 0) return '選擇上課時段';
    return '已選 $count 個時段';
  }

  void _toggleCredit(int credit) {
    setState(() {
      if (!_credits.add(credit)) {
        _credits.remove(credit);
      }
    });
  }

  void _toggleClassTime(String value) {
    setState(() {
      if (!_classTimes.add(value)) {
        _classTimes.remove(value);
      }
    });
  }

  Future<void> _showClassTimePicker() async {
    final nextValues = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return DraftClassTimePickerSheet(classTimes: _classTimes);
      },
    );
    if (nextValues == null) return;
    setState(() => _classTimes = nextValues);
  }

  void _clearFilters() {
    _classNoController.clear();
    _serialNoController.clear();
    _departmentNameController.clear();
    _collegeNameController.clear();
    _instructorController.clear();
    setState(() {
      _courseType = null;
      _credits.clear();
      _hasVacancy = null;
      _classTimes = {};
    });
  }

  void _applyFilters() {
    unawaited(
      _notifier
          .applyFilters(
            classNo: _classNoController.text,
            serialNo: _serialNoController.text,
            departmentName: _departmentNameController.text,
            collegeName: _collegeNameController.text,
            instructor: _instructorController.text,
            courseType: _courseType,
            credits: _credits,
            hasVacancy: _hasVacancy,
            classTimes: _classTimes,
          )
          .then((_) {
            if (mounted) Navigator.of(context).pop();
          }),
    );
  }
}

class _AdvancedFilterHeader extends StatelessWidget {
  const _AdvancedFilterHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('進階查詢', style: Theme.of(context).textTheme.titleLarge),
        ),
        IconButton(
          tooltip: '關閉',
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _AdvancedFilterActions extends StatelessWidget {
  const _AdvancedFilterActions({
    required this.isLoading,
    required this.onApply,
    required this.onClear,
  });

  final bool isLoading;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isLoading ? null : onApply,
            icon: const Icon(Icons.tune),
            label: const Text('套用查詢'),
          ),
        ),
        const SizedBox(width: 8.0),
        OutlinedButton.icon(
          onPressed: isLoading ? null : onClear,
          icon: const Icon(Icons.close),
          label: const Text('清除'),
        ),
      ],
    );
  }
}

class _AdvancedSearchFields extends StatelessWidget {
  const _AdvancedSearchFields({
    required this.enabled,
    required this.classNoController,
    required this.serialNoController,
    required this.departmentNameController,
    required this.collegeNameController,
    required this.instructorController,
    required this.onSubmitted,
  });

  final bool enabled;
  final TextEditingController classNoController;
  final TextEditingController serialNoController;
  final TextEditingController departmentNameController;
  final TextEditingController collegeNameController;
  final TextEditingController instructorController;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560.0;
        final fields = [
          _SearchTextField(
            controller: classNoController,
            enabled: enabled,
            label: '課號',
            hintText: '',
            icon: Icons.tag_outlined,
            onSubmitted: onSubmitted,
          ),
          _SearchTextField(
            controller: serialNoController,
            enabled: enabled,
            label: '流水號',
            hintText: '',
            icon: Icons.confirmation_number_outlined,
            onSubmitted: onSubmitted,
          ),
          _SearchTextField(
            controller: departmentNameController,
            enabled: enabled,
            label: '系所',
            hintText: '',
            icon: Icons.apartment_outlined,
            onSubmitted: onSubmitted,
          ),
          _SearchTextField(
            controller: collegeNameController,
            enabled: enabled,
            label: '學院',
            hintText: '',
            icon: Icons.account_balance_outlined,
            onSubmitted: onSubmitted,
          ),
          _SearchTextField(
            controller: instructorController,
            enabled: enabled,
            label: '授課教師',
            hintText: '',
            icon: Icons.person_search_outlined,
            onSubmitted: onSubmitted,
          ),
        ];

        if (!isWide) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                fields[index],
                if (index < fields.length - 1) const SizedBox(height: 8.0),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var index = 0; index < fields.length; index += 2) ...[
              Row(
                children: [
                  Expanded(child: fields[index]),
                  const SizedBox(width: 8.0),
                  if (index + 1 < fields.length)
                    Expanded(child: fields[index + 1])
                  else
                    const Spacer(),
                ],
              ),
              if (index < fields.length - 2) const SizedBox(height: 8.0),
            ],
          ],
        );
      },
    );
  }
}

class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String hintText;
  final IconData icon;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: (_) => onSubmitted(),
    );
  }
}

class _DraftCreditFilterGrid extends StatelessWidget {
  const _DraftCreditFilterGrid({
    required this.selectedCredits,
    required this.enabled,
    required this.onToggle,
  });

  final Set<int> selectedCredits;
  final bool enabled;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columnCount = 3;
        const spacing = 8.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final credit in _creditOptions)
              SizedBox(
                width: itemWidth,
                child: FilterChip(
                  showCheckmark: false,
                  label: Center(child: Text('$credit 學分')),
                  selected: selectedCredits.contains(credit),
                  onSelected: enabled ? (_) => onToggle(credit) : null,
                ),
              ),
          ],
        );
      },
    );
  }
}
