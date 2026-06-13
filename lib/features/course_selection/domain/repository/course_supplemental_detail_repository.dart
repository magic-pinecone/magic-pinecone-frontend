import 'package:magic_pinecone/features/course_selection/domain/models/course_detail_models.dart';

abstract class CourseSupplementalDetailRepository {
  Future<CourseSupplementalDetail?> findBySerialNo(String serialNo);
}
