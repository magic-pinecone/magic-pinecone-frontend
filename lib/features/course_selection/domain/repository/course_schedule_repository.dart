import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';

abstract class CourseScheduleRepository {
  CourseScheduleSnapshot loadSchedule();
}
