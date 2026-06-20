import 'package:magic_pinecone/features/course_selection/data/data_sources/course_schedule_catalog.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/repository/course_schedule_repository.dart';

class StaticCourseScheduleRepository implements CourseScheduleRepository {
  const StaticCourseScheduleRepository();

  @override
  CourseScheduleSnapshot loadSchedule() {
    return const CourseScheduleSnapshot(
      courses: mockScheduledCourses,
      weekDays: timetableWeekDays,
      periods: timetablePeriods,
    );
  }
}
