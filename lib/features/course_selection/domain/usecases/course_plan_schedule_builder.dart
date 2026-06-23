import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';

class CoursePlanScheduleBuilder {
  const CoursePlanScheduleBuilder();

  CourseScheduleSnapshot buildSyncedSchedule({
    required CourseScheduleSnapshot baseSchedule,
    required Iterable<CourseItem> selectedCourses,
  }) {
    final syncedCourses = selectedCourses.expand(
      (course) => courseToScheduledCourses(course, baseSchedule.periods),
    );

    return CourseScheduleSnapshot(
      courses: [...baseSchedule.courses, ...syncedCourses],
      weekDays: baseSchedule.weekDays,
      periods: baseSchedule.periods,
    );
  }

  CourseScheduleSnapshot omitWeekends(CourseScheduleSnapshot snapshot) {
    return CourseScheduleSnapshot(
      courses: snapshot.courses
          .where((course) => course.dayIndex < 5)
          .toList(growable: false),
      weekDays: snapshot.weekDays.take(5).toList(growable: false),
      periods: snapshot.periods,
    );
  }

  bool canSyncToTimetable({
    required CourseItem course,
    required List<String> periods,
  }) {
    return courseToScheduledCourses(course, periods).isNotEmpty;
  }

  bool canFitCurrentTimetable({
    required CourseItem course,
    required CourseScheduleSnapshot snapshot,
    required Set<String> occupiedSlotIds,
  }) {
    final candidateCourses = courseToScheduledCourses(course, snapshot.periods);
    if (candidateCourses.isEmpty) return false;

    final candidateSlotIds = candidateCourses.expand(occupiedSlots);
    return candidateSlotIds.every((slot) => !occupiedSlotIds.contains(slot));
  }

  int conflictSlotCount(CourseScheduleSnapshot snapshot) {
    final slotCounts = <String, int>{};
    for (final course in snapshot.courses) {
      for (final slot in occupiedSlots(course)) {
        slotCounts.update(slot, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return slotCounts.values.where((count) => count > 1).length;
  }

  Iterable<String> occupiedSlots(ScheduledCourse course) sync* {
    for (var index = 0; index < course.length; index++) {
      yield '${course.dayIndex}:${course.startPeriodIndex + index}';
    }
  }

  /// Converts raw course class times into timetable blocks using the active
  /// period definition, so the mapper is not tied to NCU's current labels.
  /// And we can possibly supports NCCU, NYCU, and NTHU for inter-uni course
  /// selection in the future.
  List<ScheduledCourse> courseToScheduledCourses(
    CourseItem course,
    List<String> periods,
  ) {
    final slots = <_CourseTimeSlot>[];

    for (final classTime in course.classTimes) {
      final parts = classTime.split('-');
      if (parts.length != 2) continue;

      final day = int.tryParse(parts[0]);
      if (day == null || day < 1 || day > 7) continue;

      final periodIndex = periods.indexOf(parts[1]);
      if (periodIndex < 0) continue;

      slots.add(_CourseTimeSlot(dayIndex: day - 1, periodIndex: periodIndex));
    }

    slots.sort((a, b) {
      final dayComparison = a.dayIndex.compareTo(b.dayIndex);
      if (dayComparison != 0) return dayComparison;
      return a.periodIndex.compareTo(b.periodIndex);
    });

    final courses = <ScheduledCourse>[];
    var index = 0;
    while (index < slots.length) {
      final start = slots[index];
      var length = 1;
      index += 1;

      while (index < slots.length &&
          slots[index].dayIndex == start.dayIndex &&
          slots[index].periodIndex == start.periodIndex + length) {
        length += 1;
        index += 1;
      }

      courses.add(
        ScheduledCourse(
          name: course.title,
          serialNo: course.serialNo,
          dayIndex: start.dayIndex,
          startPeriodIndex: start.periodIndex,
          length: length,
          location: course.classNo,
          category: course.courseTypeText,
        ),
      );
    }

    return courses;
  }
}

class _CourseTimeSlot {
  const _CourseTimeSlot({required this.dayIndex, required this.periodIndex});

  final int dayIndex;
  final int periodIndex;
}
