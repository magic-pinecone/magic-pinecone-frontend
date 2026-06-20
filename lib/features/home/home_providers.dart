import 'package:magic_pinecone/features/home/data/repositories/home_dashboard_repository_impl.dart';
import 'package:magic_pinecone/features/home/domain/repository/home_dashboard_repository.dart';
import 'package:magic_pinecone/features/home/domain/usecases/load_home_dashboard_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@riverpod
HomeDashboardRepository homeDashboardRepository(Ref ref) {
  return const StaticHomeDashboardRepository();
}

@riverpod
LoadHomeDashboardUseCase loadHomeDashboardUseCase(Ref ref) {
  return LoadHomeDashboardUseCase(ref.watch(homeDashboardRepositoryProvider));
}
