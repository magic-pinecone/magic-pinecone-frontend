import 'package:magic_pinecone/features/news/data/data_sources/scholarship_api_service.dart';
import 'package:magic_pinecone/features/news/domain/models/scholarship_item.dart';
import 'package:magic_pinecone/features/news/domain/repository/scholarship_repository.dart';

class RemoteScholarshipRepository implements ScholarshipRepository {
  RemoteScholarshipRepository({required this.service});

  final ScholarshipApiService service;

  @override
  Future<List<ScholarshipItem>> fetchScholarships() async {
    final result = await service.fetchScholarships();
    return result.scholarships
        .map(
          (scholarship) => ScholarshipItem(
            id: scholarship.id,
            category: scholarship.category,
            title: scholarship.title,
            contentSummary: scholarship.contentSummary,
            downloadLink: scholarship.downloadLink,
          ),
        )
        .toList(growable: false);
  }
}
