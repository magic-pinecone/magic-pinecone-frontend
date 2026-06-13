import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/home/domain/models/home_dashboard_models.dart';
import 'package:magic_pinecone/features/home/domain/repository/home_dashboard_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_home_dashboard_use_case.g.dart';

class LoadHomeDashboardUseCase {
  const LoadHomeDashboardUseCase(this._repository);

  final HomeDashboardRepository _repository;

  HomeDashboardSnapshot execute() {
    return _repository.loadDashboard();
  }
}

@riverpod
LoadHomeDashboardUseCase loadHomeDashboardUseCase(Ref ref) {
  return LoadHomeDashboardUseCase(ref.watch(homeDashboardRepositoryProvider));
}
