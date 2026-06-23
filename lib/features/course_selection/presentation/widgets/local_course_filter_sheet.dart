import 'package:flutter/material.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_layout.dart';

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
  late final ValueNotifier<LocalCourseFilterState> _draft =
      ValueNotifier<LocalCourseFilterState>(_initialState());

  @override
  void didUpdateWidget(covariant LocalCourseFilterSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextState = _initialState();
    if (_draft.value != nextState) {
      _draft.value = nextState;
    }
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LocalCourseFilterState>(
      valueListenable: _draft,
      builder: (context, draft, _) {
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
                value: draft.onlyShowTimetableCompatibleCourses,
                onChanged: (value) {
                  _draft.value = draft.copyWith(
                    onlyShowTimetableCompatibleCourses: value,
                  );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.checklist_outlined),
                title: const Text('只顯示已加入課表的課程'),
                value: draft.onlyShowSelectedCourses,
                onChanged: (value) {
                  _draft.value = draft.copyWith(onlyShowSelectedCourses: value);
                },
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(draft),
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
      },
    );
  }

  LocalCourseFilterState _initialState() {
    return LocalCourseFilterState(
      onlyShowTimetableCompatibleCourses:
          widget.onlyShowTimetableCompatibleCourses,
      onlyShowSelectedCourses: widget.onlyShowSelectedCourses,
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

  LocalCourseFilterState copyWith({
    bool? onlyShowTimetableCompatibleCourses,
    bool? onlyShowSelectedCourses,
  }) {
    return LocalCourseFilterState(
      onlyShowTimetableCompatibleCourses:
          onlyShowTimetableCompatibleCourses ??
          this.onlyShowTimetableCompatibleCourses,
      onlyShowSelectedCourses:
          onlyShowSelectedCourses ?? this.onlyShowSelectedCourses,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LocalCourseFilterState &&
            other.onlyShowTimetableCompatibleCourses ==
                onlyShowTimetableCompatibleCourses &&
            other.onlyShowSelectedCourses == onlyShowSelectedCourses;
  }

  @override
  int get hashCode {
    return Object.hash(
      onlyShowTimetableCompatibleCourses,
      onlyShowSelectedCourses,
    );
  }
}
