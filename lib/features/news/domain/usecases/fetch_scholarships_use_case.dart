import 'package:magic_pinecone/features/news/domain/models/scholarship_item.dart';
import 'package:magic_pinecone/features/news/domain/repository/scholarship_repository.dart';

class FetchScholarshipsUseCase {
  const FetchScholarshipsUseCase(this._repository);

  final ScholarshipRepository _repository;

  Future<List<ScholarshipItem>> execute() {
    return _repository.fetchScholarships();
  }
}
