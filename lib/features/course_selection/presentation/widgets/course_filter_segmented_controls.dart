import 'package:flutter/material.dart';

enum _CourseTypeFilter { all, required, elective }

enum _VacancyFilter { all, available, full }

class DraftCourseTypeSegmentedControl extends StatelessWidget {
  const DraftCourseTypeSegmentedControl({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / 3;
        return SegmentedButton<_CourseTypeFilter>(
          showSelectedIcon: false,
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(segmentWidth, 44.0)),
          ),
          segments: const [
            ButtonSegment(value: _CourseTypeFilter.all, label: Text('全部')),
            ButtonSegment(value: _CourseTypeFilter.required, label: Text('必修')),
            ButtonSegment(value: _CourseTypeFilter.elective, label: Text('選修')),
          ],
          selected: {_selectedFilter},
          onSelectionChanged: enabled
              ? (values) => onChanged(_toCourseType(values.single))
              : null,
        );
      },
    );
  }

  _CourseTypeFilter get _selectedFilter {
    return switch (value) {
      'REQUIRED' => _CourseTypeFilter.required,
      'ELECTIVE' => _CourseTypeFilter.elective,
      _ => _CourseTypeFilter.all,
    };
  }

  String? _toCourseType(_CourseTypeFilter filter) {
    return switch (filter) {
      _CourseTypeFilter.all => null,
      _CourseTypeFilter.required => 'REQUIRED',
      _CourseTypeFilter.elective => 'ELECTIVE',
    };
  }
}

class DraftVacancySegmentedControl extends StatelessWidget {
  const DraftVacancySegmentedControl({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool? value;
  final bool enabled;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / 3;
        return SegmentedButton<_VacancyFilter>(
          showSelectedIcon: false,
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(segmentWidth, 44.0)),
          ),
          segments: const [
            ButtonSegment(value: _VacancyFilter.all, label: Text('全部')),
            ButtonSegment(value: _VacancyFilter.available, label: Text('尚有名額')),
            ButtonSegment(value: _VacancyFilter.full, label: Text('已額滿')),
          ],
          selected: {_selectedFilter},
          onSelectionChanged: enabled
              ? (values) => onChanged(_toHasVacancy(values.single))
              : null,
        );
      },
    );
  }

  _VacancyFilter get _selectedFilter {
    return switch (value) {
      true => _VacancyFilter.available,
      false => _VacancyFilter.full,
      null => _VacancyFilter.all,
    };
  }

  bool? _toHasVacancy(_VacancyFilter filter) {
    return switch (filter) {
      _VacancyFilter.all => null,
      _VacancyFilter.available => true,
      _VacancyFilter.full => false,
    };
  }
}
