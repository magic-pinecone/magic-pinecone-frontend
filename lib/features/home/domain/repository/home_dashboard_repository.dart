import 'package:magic_pinecone/features/home/domain/models/home_dashboard_models.dart';

abstract class HomeDashboardRepository {
  HomeDashboardSnapshot loadDashboard();
}
