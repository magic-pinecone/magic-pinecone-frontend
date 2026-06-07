import 'package:magic_pinecone/features/course_selection/data/course_schedule_catalog.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';

abstract class CourseScheduleRepository {
  CourseScheduleSnapshot loadSchedule();
}

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
