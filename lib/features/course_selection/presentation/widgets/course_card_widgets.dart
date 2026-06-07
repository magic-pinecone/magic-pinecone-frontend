import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_detail_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_layout.dart';
import 'package:magic_pinecone/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_detail_row.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseResultSummary extends StatelessWidget {
  const CourseResultSummary({
    super.key,
    required this.controller,
    required this.displayedCourseCount,
    required this.localFilterActive,
    required this.localFilterTotalCount,
    required this.onFilterPressed,
  });

  final CourseSelectionController controller;
  final int displayedCourseCount;
  final bool localFilterActive;
  final int localFilterTotalCount;
  final VoidCallback onFilterPressed;

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
                      : _courseCountText(),
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
            )
          else
            IconButton(
              tooltip: '檢視選項',
              isSelected: localFilterActive,
              onPressed: onFilterPressed,
              icon: const Icon(Icons.filter_list),
              selectedIcon: const Icon(Icons.filter_list),
            ),
        ],
      ),
    );
  }

  String _courseCountText() {
    if (localFilterActive) {
      return '顯示 $displayedCourseCount / $localFilterTotalCount 門課程';
    }
    return '顯示 ${controller.courses.length} / ${controller.totalCount} 門課程';
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

class CourseListTile extends StatelessWidget {
  const CourseListTile({
    super.key,
    required this.course,
    required this.isSelected,
    required this.canSyncToTimetable,
    required this.alignActionsToBottom,
    required this.onTap,
    required this.onSyncToggle,
  });

  final CourseItem course;
  final bool isSelected;
  final bool canSyncToTimetable;
  final bool alignActionsToBottom;
  final VoidCallback onTap;
  final VoidCallback onSyncToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actionRow = Row(
      children: [
        Icon(Icons.schedule, size: 16.0, color: colorScheme.primary),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(
            course.classTimeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8.0),
        _CourseSyncButton(
          isSelected: isSelected,
          canSyncToTimetable: canSyncToTimetable,
          onPressed: onSyncToggle,
        ),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.brightness == Brightness.light
          ? Colors.white
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _CourseTypeBadge(label: course.courseTypeText),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                '${course.classNo} · ${course.creditText} 學分 · ${course.teacherText}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: [
                  _CourseMetaChip(
                    icon: Icons.account_balance_outlined,
                    label: course.openingUnitText,
                  ),
                  _CourseMetaChip(
                    icon: Icons.groups_outlined,
                    label: course.enrollmentText,
                  ),
                  if (course.showsPasswordCardHint)
                    _CourseMetaChip(
                      icon: Icons.vpn_key_outlined,
                      label: course.passwordCardText,
                    ),
                ],
              ),
              if (alignActionsToBottom) const Spacer(),
              const SizedBox(height: 8.0),
              actionRow,
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseSyncButton extends StatelessWidget {
  const _CourseSyncButton({
    required this.isSelected,
    required this.canSyncToTimetable,
    required this.onPressed,
  });

  final bool isSelected;
  final bool canSyncToTimetable;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.close),
        label: const Text('移除'),
      );
    }

    return FilledButton.icon(
      onPressed: canSyncToTimetable ? onPressed : null,
      icon: const Icon(Icons.add),
      label: Text(canSyncToTimetable ? '加入' : '無時段'),
    );
  }
}

class _CourseTypeBadge extends StatelessWidget {
  const _CourseTypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.0,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CourseMetaChip extends StatelessWidget {
  const _CourseMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.0, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4.0),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseDetailsSheet extends StatelessWidget {
  const CourseDetailsSheet({
    super.key,
    required this.course,
    required this._toggleCourseSelection,
    required this._isCourseSelected,
  });

  final CourseItem course;
  final ValueChanged<CourseItem> _toggleCourseSelection;
  final bool Function(CourseItem course) _isCourseSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _CourseDetailsContent(
        course: course,
        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
        toggleCourseSelection: _toggleCourseSelection,
        isCourseSelected: _isCourseSelected,
      ),
    );
  }
}

class CourseDetailsDialog extends StatelessWidget {
  const CourseDetailsDialog({
    super.key,
    required this.course,
    required this.supplementalDetail,
    required this._toggleCourseSelection,
    required this._isCourseSelected,
  });

  final CourseItem course;
  final Future<CourseSupplementalDetail?> supplementalDetail;
  final ValueChanged<CourseItem> _toggleCourseSelection;
  final bool Function(CourseItem course) _isCourseSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(32.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: CourseSelectionLayout.maxCourseDetailsDialogWidth,
        ),
        child: SizedBox(
          key: const ValueKey('course-details-dialog-body'),
          height: CourseSelectionLayout.courseDetailsDialogHeight,
          child: FutureBuilder<CourseSupplementalDetail?>(
            future: supplementalDetail,
            builder: (context, snapshot) {
              return _CourseDetailsContent(
                course: course,
                supplementalDetail: snapshot.data,
                isLoadingSupplementalDetail:
                    snapshot.connectionState != ConnectionState.done,
                padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
                showCloseButton: true,
                useHorizontalActions: true,
                toggleCourseSelection: _toggleCourseSelection,
                isCourseSelected: _isCourseSelected,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CourseDetailsContent extends StatefulWidget {
  const _CourseDetailsContent({
    required this.course,
    required this.padding,
    required this._toggleCourseSelection,
    required this._isCourseSelected,
    this.supplementalDetail,
    this.isLoadingSupplementalDetail = false,
    this.showCloseButton = false,
    this.useHorizontalActions = false,
  });

  final CourseItem course;
  final EdgeInsetsGeometry padding;
  final CourseSupplementalDetail? supplementalDetail;
  final bool isLoadingSupplementalDetail;
  final bool showCloseButton;
  final bool useHorizontalActions;
  final ValueChanged<CourseItem> _toggleCourseSelection;
  final bool Function(CourseItem course) _isCourseSelected;

  @override
  State<_CourseDetailsContent> createState() => _CourseDetailsContentState();
}

class _CourseDetailsContentState extends State<_CourseDetailsContent> {
  @override
  Widget build(BuildContext context) {
    final isCourseSelected = widget._isCourseSelected(widget.course);

    final content = Column(
      mainAxisSize: widget.useHorizontalActions
          ? MainAxisSize.max
          : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: CourseSelectableText(
                      widget.course.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: _CourseTypeBadge(
                      label: widget.course.courseTypeText,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showCloseButton) ...[
              const SizedBox(width: 8.0),
              IconButton(
                tooltip: '關閉',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16.0),
        if (widget.useHorizontalActions)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('course-primary-details-scroll'),
                    child: _CoursePrimaryDetails(
                      course: widget.course,
                      supplementalDetail: widget.supplementalDetail,
                    ),
                  ),
                ),
                const VerticalDivider(width: 32.0),
                Expanded(
                  child: widget.isLoadingSupplementalDetail
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: _CourseSupplementalDetails(
                                  detail: widget.supplementalDetail,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          )
        else
          _CoursePrimaryDetails(course: widget.course),
        const SizedBox(height: 12.0),
        if (widget.useHorizontalActions)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: _toggle,
                label: Text(isCourseSelected ? '移除' : '加入'),
                icon: Icon(isCourseSelected ? Icons.close : Icons.add),
              ),
              const SizedBox(width: 8.0),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('關閉'),
              ),
            ],
          )
        else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openCourseDetailUrl(context),
              child: const Text('課程詳細資訊'),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _toggle,
              child: Text(isCourseSelected ? '移除' : '加入'),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
          ),
        ],
      ],
    );

    if (widget.useHorizontalActions) {
      return Padding(padding: widget.padding, child: content);
    }

    return SingleChildScrollView(padding: widget.padding, child: content);
  }

  void _toggle() {
    widget._toggleCourseSelection(widget.course);
    setState(() {});
  }

  void _openCourseDetailUrl(BuildContext context) {
    final navigator = Navigator.of(context);
    final targetUrl = Uri.parse(widget.course.detailUrlWithParams);

    navigator.pop();
    unawaited(launchUrl(targetUrl, webOnlyWindowName: '_blank'));
  }
}

class _CoursePrimaryDetails extends StatelessWidget {
  const _CoursePrimaryDetails({required this.course, this.supplementalDetail});

  final CourseItem course;
  final CourseSupplementalDetail? supplementalDetail;

  @override
  Widget build(BuildContext context) {
    final distributionConditionText =
        supplementalDetail?.distributionConditionText ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CourseDetailRow(
          icon: Icons.confirmation_number_outlined,
          label: '課號',
          value: '${course.classNo} / ${course.serialNo}',
        ),
        CourseDetailRow(
          icon: Icons.person_outline,
          label: '授課教師',
          value: course.teacherText,
        ),
        CourseDetailRow(
          icon: Icons.schedule,
          label: '上課時間',
          value: course.classTimeText,
        ),
        CourseDetailRow(
          icon: Icons.school_outlined,
          label: '學分',
          value: '${course.creditText} 學分',
        ),
        CourseDetailRow(
          icon: Icons.groups_outlined,
          label: '選課人數',
          value: course.enrollmentText,
        ),
        CourseDetailRow(
          icon: Icons.vpn_key_outlined,
          label: '密碼卡',
          value: course.passwordCardText,
        ),
        if (course.departmentName != null || course.collegeName != null)
          CourseDetailRow(
            icon: Icons.account_balance_outlined,
            label: '開課單位',
            value: [
              if (course.collegeName != null) course.collegeName,
              if (course.departmentName != null) course.departmentName,
            ].join(' / '),
          ),
        if (distributionConditionText.isNotEmpty)
          CourseDetailRow(
            icon: Icons.rule_outlined,
            label: '分發條件',
            value: distributionConditionText,
          ),
      ],
    );
  }
}

class _CourseSupplementalDetails extends StatelessWidget {
  const _CourseSupplementalDetails({required this.detail});

  final CourseSupplementalDetail? detail;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;
    if (detail == null || !_hasDisplayedContent(detail)) {
      return const _CourseSupplementalFallback();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CourseSupplementalSection(title: '課程目標', value: detail.objectives),
        _CourseSupplementalSection(title: '課程內容', value: detail.content),
        _CourseSupplementalSection(title: '指定用書', value: detail.books),
        _CourseSupplementalSection(title: '教學方式', value: detail.teachingMethod),
        _CourseSupplementalSection(title: '評分方式', value: detail.gradingPolicy),
      ],
    );
  }

  bool _hasDisplayedContent(CourseSupplementalDetail detail) {
    return detail.objectives.isNotEmpty ||
        detail.content.isNotEmpty ||
        detail.books.isNotEmpty ||
        detail.teachingMethod.isNotEmpty ||
        detail.gradingPolicy.isNotEmpty;
  }
}

class _CourseSupplementalFallback extends StatelessWidget {
  const _CourseSupplementalFallback();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 32.0,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12.0),
          Text(
            '尚未提供課程詳細資訊',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            '目前沒有補充說明、指定用書或評分方式。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseSupplementalSection extends StatelessWidget {
  const _CourseSupplementalSection({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourseSelectableText(
            title,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4.0),
          CourseSelectableText(
            value,
            style: TextStyle(height: 1.45, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class CourseSelectableText extends StatelessWidget {
  const CourseSelectableText(this.data, {super.key, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(child: Text(data, style: style));
  }
}
