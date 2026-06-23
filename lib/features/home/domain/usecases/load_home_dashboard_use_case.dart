import 'package:magic_pinecone/features/home/domain/models/home_dashboard_models.dart';
import 'package:magic_pinecone/features/home/domain/repository/home_dashboard_repository.dart';

class LoadHomeDashboardUseCase {
  const LoadHomeDashboardUseCase(this._repository);

  final HomeDashboardRepository _repository;

  HomeDashboardSnapshot execute() {
    return _repository.loadDashboard();
  }
}
