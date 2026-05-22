import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/course_selection/data/course_schedule_repository.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';

void main() {
  group('CourseSelectionController', () {
    test('shows weekdays only by default', () {
      final controller = CourseSelectionController(
        repository: const FakeCourseScheduleRepository(),
      );

      expect(controller.showWeekends, isFalse);
      expect(controller.visibleDays, ['一', '二', '三', '四', '五']);
    });

    test('shows weekends after toggling', () {
      final controller = CourseSelectionController(
        repository: const FakeCourseScheduleRepository(),
      );

      controller.setShowWeekends(true);

      expect(controller.showWeekends, isTrue);
      expect(controller.visibleDays, ['一', '二', '三', '四', '五', '六', '日']);
    });
  });
}

class FakeCourseScheduleRepository implements CourseScheduleRepository {
  const FakeCourseScheduleRepository();

  @override
  CourseScheduleSnapshot loadSchedule() {
    return const CourseScheduleSnapshot(
      courses: [],
      weekDays: ['一', '二', '三', '四', '五', '六', '日'],
      periods: ['1', '2', '3'],
    );
  }
}
