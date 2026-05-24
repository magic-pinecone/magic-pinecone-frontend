import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/app/app_dependencies.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/models/course_schedule_models.dart';
import 'package:prototype/features/home/data/home_dashboard_repository.dart';
import 'package:prototype/features/home/models/home_dashboard_models.dart';
import 'package:prototype/features/home/presentation/home_page.dart';
import 'package:prototype/features/home/presentation/view_models/home_view_model.dart';

void main() {
  testWidgets('HomePage renders dashboard sections and course previews', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        HomePage(
          viewModel: HomeViewModel(
            repository: const FakeHomeDashboardRepository(),
          ),
        ),
      ),
    );

    expect(find.text('接下來的課程'), findsOneWidget);
    expect(find.text('捷徑'), findsOneWidget);
    expect(find.text('快速功能表'), findsOneWidget);
    expect(find.text('計算機概論 I'), findsOneWidget);
    expect(find.text('離散數學'), findsOneWidget);
    expect(find.text('英文溝通'), findsOneWidget);
  });

  testWidgets('HomePage quick action navigates to course selection page', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        HomePage(
          viewModel: HomeViewModel(
            repository: const FakeHomeDashboardRepository(),
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('選課系統'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('選課系統'));
    await tester.pumpAndSettle();

    expect(find.text('課程查詢'), findsOneWidget);
  });

  testWidgets('HomePage portal quick action opens filtered portal page', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        HomePage(
          viewModel: HomeViewModel(
            repository: const FakeHomeDashboardRepository(),
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('成績查詢'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('成績查詢'));
    await tester.pumpAndSettle();

    expect(find.text('校務系統'), findsOneWidget);
    expect(find.text('成績查詢'), findsWidgets);
    expect(find.text('NCU Mail'), findsNothing);
  });
}

Widget _buildTestApp(Widget child) {
  return AppScope(
    dependencies: AppDependencies(courseRepository: FakeCourseRepository()),
    child: MaterialApp(home: child),
  );
}

class FakeCourseRepository implements CourseRepository {
  @override
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentId,
    String? collegeId,
    String? courseType,
    int offset = 0,
    int limit = 100,
  }) async {
    return const CourseSearchResult(totalCount: 0, courses: []);
  }
}

class FakeHomeDashboardRepository implements HomeDashboardRepository {
  const FakeHomeDashboardRepository();

  @override
  HomeDashboardSnapshot loadDashboard() {
    return const HomeDashboardSnapshot(
      coursePreviews: [
        HomeCoursePreview(
          courseName: '計算機概論 I',
          courseTime: '週四 13:00-16:00',
          courseLocation: '工程五館 A207',
        ),
        HomeCoursePreview(
          courseName: '離散數學',
          courseTime: '週五 09:00-12:00',
          courseLocation: '鴻經館 M116',
        ),
        HomeCoursePreview(
          courseName: '英文溝通',
          courseTime: '週五 13:00-15:00',
          courseLocation: '教研大樓 204',
          category: '選修',
        ),
      ],
      shortcuts: [
        HomeShortcutItem(
          icon: Icons.school,
          label: '校務系統',
          color: Color(0xFF4A90D9),
        ),
      ],
      quickActionRows: [
        [
          HomeQuickActionItem(
            icon: Icons.book,
            label: '成績查詢',
            destination: HomePortalDestination(initialSearchQuery: '成績查詢'),
          ),
          HomeQuickActionItem(
            icon: Icons.explore,
            label: '選課系統',
            destination: HomeCourseSelectionDestination(),
          ),
        ],
      ],
    );
  }
}
