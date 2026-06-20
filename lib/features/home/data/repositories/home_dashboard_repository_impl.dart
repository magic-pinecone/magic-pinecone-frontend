import 'package:magic_pinecone/features/home/data/data_sources/home_dashboard_catalog.dart';
import 'package:magic_pinecone/features/home/domain/models/home_dashboard_models.dart';
import 'package:magic_pinecone/features/home/domain/repository/home_dashboard_repository.dart';

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
