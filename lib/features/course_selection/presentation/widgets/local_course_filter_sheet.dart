import 'package:flutter/material.dart';
import 'package:prototype/features/course_selection/presentation/course_selection_layout.dart';

class LocalCourseFilterSheet extends StatefulWidget {
  const LocalCourseFilterSheet({
    super.key,
    required this.onlyShowTimetableCompatibleCourses,
    required this.onlyShowSelectedCourses,
    required this.useDialogLayout,
  });

  final bool onlyShowTimetableCompatibleCourses;
  final bool onlyShowSelectedCourses;
  final bool useDialogLayout;

  @override
  State<LocalCourseFilterSheet> createState() => _LocalCourseFilterSheetState();
}

class _LocalCourseFilterSheetState extends State<LocalCourseFilterSheet> {
  late bool _onlyShowTimetableCompatibleCourses;
  late bool _onlyShowSelectedCourses;

  @override
  void initState() {
    super.initState();
    _onlyShowTimetableCompatibleCourses =
        widget.onlyShowTimetableCompatibleCourses;
    _onlyShowSelectedCourses = widget.onlyShowSelectedCourses;
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: widget.useDialogLayout
          ? const EdgeInsets.all(24.0)
          : const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('檢視選項', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8.0),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.event_available_outlined),
            title: const Text('只顯示本頁可加入課表的課程'),
            value: _onlyShowTimetableCompatibleCourses,
            onChanged: (value) {
              setState(() => _onlyShowTimetableCompatibleCourses = value);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.checklist_outlined),
            title: const Text('只顯示已加入課表的課程'),
            value: _onlyShowSelectedCourses,
            onChanged: (value) {
              setState(() => _onlyShowSelectedCourses = value);
            },
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(
                LocalCourseFilterState(
                  onlyShowTimetableCompatibleCourses:
                      _onlyShowTimetableCompatibleCourses,
                  onlyShowSelectedCourses: _onlyShowSelectedCourses,
                ),
              ),
              child: const Text('完成'),
            ),
          ),
        ],
      ),
    );

    if (widget.useDialogLayout) {
      return content;
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
}

class LocalCourseFilterState {
  const LocalCourseFilterState({
    required this.onlyShowTimetableCompatibleCourses,
    required this.onlyShowSelectedCourses,
  });

  final bool onlyShowTimetableCompatibleCourses;
  final bool onlyShowSelectedCourses;
}
