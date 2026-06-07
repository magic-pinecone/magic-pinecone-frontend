import 'package:magic_pinecone/features/news/data/scholarship_api_service.dart';
import 'package:magic_pinecone/features/news/models/scholarship_item.dart';

abstract class ScholarshipRepository {
  Future<List<ScholarshipItem>> fetchScholarships();
}

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
