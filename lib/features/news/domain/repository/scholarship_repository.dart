import 'package:magic_pinecone/features/news/domain/models/scholarship_item.dart';

abstract class ScholarshipRepository {
  Future<List<ScholarshipItem>> fetchScholarships();
}
