import 'package:magic_pinecone/features/home/data/home_dashboard_catalog.dart';
import 'package:magic_pinecone/features/home/models/home_dashboard_models.dart';

abstract class HomeDashboardRepository {
  HomeDashboardSnapshot loadDashboard();
}

class StaticHomeDashboardRepository implements HomeDashboardRepository {
  const StaticHomeDashboardRepository();

  @override
  HomeDashboardSnapshot loadDashboard() {
    return const HomeDashboardSnapshot(
      coursePreviews: homeCoursePreviews,
      shortcuts: homeShortcutItems,
      quickActionRows: homeQuickActionRows,
    );
  }
}
