import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/home/domain/models/home_dashboard_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeViewSnapshot build() {
    final repository = ref.watch(homeDashboardRepositoryProvider);
    final dashboard = repository.loadDashboard();
    return HomeViewSnapshot(
      coursePreviews: List.unmodifiable(dashboard.coursePreviews),
      shortcuts: List.unmodifiable(dashboard.shortcuts),
      quickActionRows: dashboard.quickActionRows
          .map(List<HomeQuickActionItem>.unmodifiable)
          .toList(growable: false),
    );
  }
}

class HomeViewSnapshot {
  HomeViewSnapshot({
    required this.coursePreviews,
    required this.shortcuts,
    required this.quickActionRows,
  });

  final List<HomeCoursePreview> coursePreviews;
  // TODO: for these two, we keep it so a configurable home dashboard can be implemented in the future. But we might want to introduce a more generic "HomeDashboardItem" model that can represent both shortcuts and quick actions, since they are quite similar in nature.
  final List<HomeShortcutItem> shortcuts;
  final List<List<HomeQuickActionItem>> quickActionRows;
}
