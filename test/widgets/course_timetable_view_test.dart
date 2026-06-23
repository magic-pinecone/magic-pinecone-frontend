import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:magic_pinecone/features/course_selection/presentation/widgets/course_timetable_view.dart';

void main() {
  testWidgets('CourseTimetableView animates save success in the action pill', (
    tester,
  ) async {
    var saved = false;

    await tester.pumpWidget(
      _TestTimetableView(
        onSavePressed: () async {
          saved = true;
        },
        onDiscardPressed: () async {},
      ),
    );

    expect(find.text('還原'), findsOneWidget);
    expect(find.text('儲存'), findsOneWidget);
    expect(find.text('分享'), findsOneWidget);

    await tester.tap(find.text('儲存'));
    await tester.pump();

    expect(find.text('還原'), findsNothing);
    expect(find.text('分享'), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));

    expect(saved, isTrue);
    expect(find.text('已儲存'), findsOneWidget);
    expect(find.text('還原'), findsNothing);
    expect(find.text('儲存'), findsNothing);
    expect(find.text('分享'), findsNothing);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('儲存'), findsNothing);
    expect(find.text('還原'), findsNothing);
    expect(find.text('已儲存'), findsNothing);
  });

  testWidgets('CourseTimetableView removes restore without success copy', (
    tester,
  ) async {
    var restored = false;

    await tester.pumpWidget(
      _TestTimetableView(
        onSavePressed: () async {},
        onDiscardPressed: () async {
          restored = true;
        },
      ),
    );

    await tester.tap(find.text('還原'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(restored, isTrue);
    expect(find.text('已還原'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('還原'), findsNothing);
    expect(find.text('儲存'), findsNothing);
    expect(find.text('已還原'), findsNothing);
  });
}

class _TestTimetableView extends StatefulWidget {
  const _TestTimetableView({
    required this.onSavePressed,
    required this.onDiscardPressed,
  });

  final Future<void> Function() onSavePressed;
  final Future<void> Function() onDiscardPressed;

  @override
  State<_TestTimetableView> createState() => _TestTimetableViewState();
}

class _TestTimetableViewState extends State<_TestTimetableView> {
  var _showSaveAction = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CourseTimetableView(
          snapshot: const CourseScheduleSnapshot(
            courses: [],
            weekDays: ['一', '二', '三', '四', '五'],
            periods: ['1', '2'],
          ),
          totalCredits: 3,
          conflictSlotCount: 0,
          showSaveAction: _showSaveAction,
          showPreviewHint: false,
          onSavePressed: () async {
            await widget.onSavePressed();
            if (!mounted) return;
            setState(() {
              _showSaveAction = false;
            });
          },
          onDiscardPressed: () async {
            await widget.onDiscardPressed();
            if (!mounted) return;
            setState(() {
              _showSaveAction = false;
            });
          },
          onSharePressed: null,
          onCourseTap: (_) {},
        ),
      ),
    );
  }
}
