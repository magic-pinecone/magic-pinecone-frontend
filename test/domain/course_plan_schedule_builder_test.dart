import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/domain/usecases/course_plan_schedule_builder.dart';

void main() {
  const builder = CoursePlanScheduleBuilder();
  const periods = ['1', '2', '3', '4'];

  group('CoursePlanScheduleBuilder', () {
    test('converts course class times into contiguous scheduled blocks', () {
      const course = CourseItem(
        serialNo: '12345',
        classNo: 'CS101',
        title: '程式設計',
        credit: 3,
        teachers: ['王小明'],
        classTimes: ['1-1', '1-2', '1-4', '2-3', 'bad', '8-1', '1-X'],
      );

      final scheduledCourses = builder.courseToScheduledCourses(
        course,
        periods,
      );

      expect(scheduledCourses, hasLength(3));
      expect(scheduledCourses[0].dayIndex, 0);
      expect(scheduledCourses[0].startPeriodIndex, 0);
      expect(scheduledCourses[0].length, 2);
      expect(scheduledCourses[1].dayIndex, 0);
      expect(scheduledCourses[1].startPeriodIndex, 3);
      expect(scheduledCourses[1].length, 1);
      expect(scheduledCourses[2].dayIndex, 1);
      expect(scheduledCourses[2].startPeriodIndex, 2);
      expect(scheduledCourses[2].length, 1);
    });

    test('builds synced schedule and detects conflicts', () {
      const baseSchedule = CourseScheduleSnapshot(
        courses: [
          ScheduledCourse(
            name: '既有課程',
            dayIndex: 0,
            startPeriodIndex: 0,
            length: 2,
            location: 'A',
          ),
        ],
        weekDays: ['一', '二', '三', '四', '五', '六', '日'],
        periods: periods,
      );
      const selectedCourse = CourseItem(
        serialNo: '12345',
        classNo: 'CS101',
        title: '程式設計',
        credit: 3,
        teachers: [],
        classTimes: ['1-2', '1-3'],
      );

      final snapshot = builder.buildSyncedSchedule(
        baseSchedule: baseSchedule,
        selectedCourses: const [selectedCourse],
      );

      final occupiedSlotsId = baseSchedule.courses
          .expand(builder.occupiedSlots)
          .toSet();

      expect(snapshot.courses, hasLength(2));
      expect(snapshot.courses.last.name, '程式設計');
      expect(builder.conflictSlotCount(snapshot), 1);
      expect(
        builder.canFitCurrentTimetable(
          course: selectedCourse,
          snapshot: baseSchedule,
          occupiedSlotIds: occupiedSlotsId,
        ),
        isFalse,
      );
    });

    test('omits weekends from timetable snapshot', () {
      const snapshot = CourseScheduleSnapshot(
        courses: [
          ScheduledCourse(
            name: '平日課程',
            dayIndex: 4,
            startPeriodIndex: 0,
            length: 1,
            location: 'A',
          ),
          ScheduledCourse(
            name: '週末課程',
            dayIndex: 5,
            startPeriodIndex: 0,
            length: 1,
            location: 'B',
          ),
        ],
        weekDays: ['一', '二', '三', '四', '五', '六', '日'],
        periods: periods,
      );

      final visibleSnapshot = builder.omitWeekends(snapshot);

      expect(visibleSnapshot.weekDays, ['一', '二', '三', '四', '五']);
      expect(visibleSnapshot.courses.single.name, '平日課程');
    });
  });
}
