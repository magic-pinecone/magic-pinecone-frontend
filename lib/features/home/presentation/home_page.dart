import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/core/navigation/app_routes.dart';
import 'package:prototype/core/widgets/owned_change_notifier_builder.dart';
import 'package:prototype/features/home/models/home_dashboard_models.dart';
import 'package:prototype/features/home/presentation/view_models/home_view_model.dart';
import 'package:prototype/features/home/presentation/widgets/home_course_card.dart';
import 'package:prototype/features/home/presentation/widgets/home_quick_action_button.dart';
import 'package:prototype/features/home/presentation/widgets/home_section_header.dart';
import 'package:prototype/features/portal/presentation/widgets/portal_shortcut_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.viewModel});

  static const _horizontalPadding = 16.0;

  final HomeViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return OwnedChangeNotifierBuilder<HomeViewModel>(
      notifier: viewModel,
      create: (context) => AppScope.of(context).createHomeViewModel(),
      builder: (context, viewModel) => Scaffold(
        appBar: AppBar(
          title: const Text(
            '神奇松果',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            _buildCourseSection(context, viewModel.coursePreviews),
            _buildShortcutSection(context, viewModel.shortcuts),
            _buildQuickActionSection(context, viewModel.quickActionRows),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSection(
    BuildContext context,
    List<HomeCoursePreview> coursePreviews,
  ) {
    return SliverMainAxisGroup(
      slivers: [
        HomeSectionHeader(
          title: '接下來的課程',
          onTap: () => context.pushCourseSelection(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: 4.0,
              ),
              itemCount: coursePreviews.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final course = coursePreviews[index];
                return HomeCourseCard(
                  courseName: course.courseName,
                  courseTime: course.courseTime,
                  courseLocation: course.courseLocation,
                  category: course.category,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutSection(
    BuildContext context,
    List<HomeShortcutItem> shortcutItems,
  ) {
    return SliverMainAxisGroup(
      slivers: [
        HomeSectionHeader(title: '捷徑', onTap: () => context.pushPortal()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: 8.0,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildListDelegate([
              for (final item in shortcutItems)
                PortalShortcutButton(
                  icon: item.icon,
                  label: item.label,
                  color: item.color,
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButtonRow(
    BuildContext context,
    List<HomeQuickActionItem> items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) const SizedBox(width: 10.0),
            HomeQuickActionButton(
              icon: items[index].icon,
              label: items[index].label,
              onPressed: () => _openQuickAction(context, items[index]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionSection(
    BuildContext context,
    List<List<HomeQuickActionItem>> quickActionRows,
  ) {
    return SliverMainAxisGroup(
      slivers: [
        const HomeSectionHeader(title: '快速功能表'),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: 4.0,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              for (final row in quickActionRows)
                _buildQuickButtonRow(context, row),
            ]),
          ),
        ),
      ],
    );
  }

  void _openQuickAction(BuildContext context, HomeQuickActionItem item) {
    switch (item.destination) {
      case HomeCourseSelectionDestination():
        context.pushCourseSelection();
      case HomePortalDestination(:final initialSearchQuery):
        context.pushPortal(initialSearchQuery: initialSearchQuery ?? '');
    }
  }
}
