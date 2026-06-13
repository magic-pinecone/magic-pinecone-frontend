import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/news/domain/models/scholarship_item.dart';
import 'package:magic_pinecone/features/news/domain/repository/scholarship_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fetch_scholarships_use_case.g.dart';

class FetchScholarshipsUseCase {
  const FetchScholarshipsUseCase(this._repository);

  final ScholarshipRepository _repository;

  Future<List<ScholarshipItem>> execute() {
    return _repository.fetchScholarships();
  }
}

@riverpod
FetchScholarshipsUseCase fetchScholarshipsUseCase(Ref ref) {
  return FetchScholarshipsUseCase(ref.watch(scholarshipRepositoryProvider));
}
