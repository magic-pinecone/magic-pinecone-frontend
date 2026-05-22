class ScheduledCourse {
  const ScheduledCourse({
    required this.name,
    required this.dayIndex,
    required this.startPeriodIndex,
    required this.length,
    required this.location,
    this.category = '必修',
  });

  final String name;
  final int dayIndex;
  final int startPeriodIndex;
  final int length;
  final String location;
  final String category;
}

class CourseScheduleSnapshot {
  const CourseScheduleSnapshot({
    required this.courses,
    required this.weekDays,
    required this.periods,
  });

  final List<ScheduledCourse> courses;
  final List<String> weekDays;
  final List<String> periods;
}
