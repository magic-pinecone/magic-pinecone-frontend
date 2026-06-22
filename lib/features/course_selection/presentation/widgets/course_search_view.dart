import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_layout.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_card_widgets.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_filter_widgets.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_result_widgets.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_state_widgets.dart';

class CourseSearchView extends ConsumerWidget {
  const CourseSearchView({
    super.key,
    required this.displayedCourses,
    required this.isCourseSelected,
    required this.canSyncToTimetable,
    required this.onCourseTap,
    required this.onCourseSyncToggle,
    required this.onLocalFilterPressed,
    required this.localFilterActive,
    required this.localFilterTotalCount,
    required this.useAdvancedFilterDialog,
  });

  final List<CourseItem> displayedCourses;
  final bool Function(CourseItem course) isCourseSelected;
  final bool Function(CourseItem course) canSyncToTimetable;
  final ValueChanged<CourseItem> onCourseTap;
  final ValueChanged<CourseItem> onCourseSyncToggle;
  final VoidCallback onLocalFilterPressed;
  final bool localFilterActive;
  final int localFilterTotalCount;
  final bool useAdvancedFilterDialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseSelectionControllerProvider);
    final notifier = ref.read(courseSelectionControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid =
            constraints.maxWidth >= CourseSelectionLayout.wideLayoutMinWidth;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CourseSelectionLayout.maxSearchContentWidth,
            ),
            child: Column(
              children: [
                CourseSearchPanel(
                  useAdvancedFilterDialog: useAdvancedFilterDialog,
                ),
                CourseResultSummary(
                  displayedCourseCount: displayedCourses.length,
                  localFilterActive: localFilterActive,
                  localFilterTotalCount: localFilterTotalCount,
                  onFilterPressed: onLocalFilterPressed,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: notifier.search,
                    child: CustomScrollView(
                      scrollCacheExtent: const ScrollCacheExtent.pixels(900.0),
                      slivers: [
                        if (state.isLoading && state.courses.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (state.error != null && state.courses.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: CourseErrorState(
                              onRetry: () => unawaited(notifier.search()),
                            ),
                          )
                        else if (displayedCourses.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: CourseEmptyState(),
                          )
                        else if (useGrid)
                          CourseResultGrid(
                            courses: displayedCourses,
                            isCourseSelected: isCourseSelected,
                            canSyncToTimetable: canSyncToTimetable,
                            onCourseTap: onCourseTap,
                            onCourseSyncToggle: onCourseSyncToggle,
                          )
                        else
                          CourseResultList(
                            courses: displayedCourses,
                            isCourseSelected: isCourseSelected,
                            canSyncToTimetable: canSyncToTimetable,
                            onCourseTap: onCourseTap,
                            onCourseSyncToggle: onCourseSyncToggle,
                          ),
                        if (!localFilterActive && state.totalCount > 0)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                CourseSelectionLayout.horizontalPadding,
                                4.0,
                                CourseSelectionLayout.horizontalPadding,
                                24.0,
                              ),
                              child: CoursePaginationControls(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
