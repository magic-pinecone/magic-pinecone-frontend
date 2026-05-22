import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/course_selection/data/course_schedule_repository.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/course_selection_page.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';

void main() {
  testWidgets('CourseSelectionPage hides weekends by default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: const FakeCourseScheduleRepository(),
          ),
        ),
      ),
    );

    expect(find.text('一'), findsOneWidget);
    expect(find.text('五'), findsOneWidget);
    expect(find.text('六'), findsNothing);
    expect(find.text('日'), findsNothing);
  });

  testWidgets('CourseSelectionPage shows weekends after toggle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: const FakeCourseScheduleRepository(),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('六'), findsOneWidget);
    expect(find.text('日'), findsOneWidget);
  });

  testWidgets('CourseSelectionPage shows course details sheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseSelectionPage(
          controller: CourseSelectionController(
            repository: const FakeCourseScheduleRepository(
              courses: [
                ScheduledCourse(
                  name: '計算機概論',
                  dayIndex: 0,
                  startPeriodIndex: 1,
                  length: 3,
                  location: '工程五館 A207',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('計算機概論'));
    await tester.pumpAndSettle();

    expect(find.text('計算機概論'), findsWidgets);
    expect(find.text('上課時間'), findsOneWidget);
    expect(find.text('週一 第 2-4 節'), findsOneWidget);
    expect(find.text('工程五館 A207'), findsOneWidget);
  });
}

class FakeCourseScheduleRepository implements CourseScheduleRepository {
  const FakeCourseScheduleRepository({
    this.courses = const [],
    this.weekDays = const ['一', '二', '三', '四', '五', '六', '日'],
    this.periods = const ['1', '2', '3', '4'],
  });

  final List<ScheduledCourse> courses;
  final List<String> weekDays;
  final List<String> periods;

  @override
  CourseScheduleSnapshot loadSchedule() {
    return CourseScheduleSnapshot(
      courses: courses,
      weekDays: weekDays,
      periods: periods,
    );
  }
}
