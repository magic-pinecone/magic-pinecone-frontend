import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/news/data/data_sources/scholarship_api_service.dart';
import 'package:magic_pinecone/features/news/data/repositories/news_digest_repository_impl.dart';
import 'package:magic_pinecone/features/news/data/repositories/scholarship_repository_impl.dart';
import 'package:magic_pinecone/features/news/domain/repository/news_digest_repository.dart';
import 'package:magic_pinecone/features/news/domain/repository/scholarship_repository.dart';
import 'package:magic_pinecone/features/news/domain/usecases/fetch_scholarships_use_case.dart';
import 'package:magic_pinecone/features/news/domain/usecases/load_news_digest_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'news_providers.g.dart';

@riverpod
NewsDigestRepository newsDigestRepository(Ref ref) {
  return const StaticNewsDigestRepository();
}

@riverpod
ScholarshipApiService scholarshipApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ScholarshipApiService(dio);
}

@riverpod
ScholarshipRepository scholarshipRepository(Ref ref) {
  final service = ref.watch(scholarshipApiServiceProvider);
  return RemoteScholarshipRepository(service: service);
}

@riverpod
LoadNewsDigestUseCase loadNewsDigestUseCase(Ref ref) {
  return LoadNewsDigestUseCase(ref.watch(newsDigestRepositoryProvider));
}

@riverpod
FetchScholarshipsUseCase fetchScholarshipsUseCase(Ref ref) {
  return FetchScholarshipsUseCase(ref.watch(scholarshipRepositoryProvider));
}
