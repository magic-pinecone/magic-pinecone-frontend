import 'package:prototype/features/news/data/scholarship_service.dart';
import 'package:prototype/features/news/models/scholarship_item.dart';

abstract class ScholarshipRepository {
  Future<List<ScholarshipItem>> fetchScholarships();
}

class RemoteScholarshipRepository implements ScholarshipRepository {
  RemoteScholarshipRepository({required ScholarshipService service})
    : _service = service;

  final ScholarshipService _service;

  @override
  Future<List<ScholarshipItem>> fetchScholarships() {
    return _service.fetchScholarships();
  }
}
