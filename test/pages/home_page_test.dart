import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/app/app_providers.dart';
import 'package:prototype/features/course_selection/data/course_repository.dart';
import 'package:prototype/features/course_selection/data/course_supplemental_detail_catalog.dart';
import 'package:prototype/features/course_selection/domain/models/course_detail_models.dart';
import 'package:prototype/features/course_selection/domain/models/course_schedule_models.dart';
import 'package:prototype/features/course_selection/presentation/view_models/course_selection_controller.dart';
import 'package:prototype/features/home/data/home_dashboard_repository.dart';
import 'package:prototype/features/home/models/home_dashboard_models.dart';
import 'package:prototype/features/home/presentation/home_page.dart';
import 'package:prototype/features/home/presentation/view_models/home_view_model.dart';
import 'package:prototype/features/portal/data/portal_authenticator.dart';
import 'package:prototype/features/portal/data/portal_shortcut_repository.dart';
import 'package:prototype/features/portal/models/portal_shortcut.dart';
import 'package:prototype/features/portal/presentation/view_models/portal_session_controller.dart';

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
  return ProviderScope(
    overrides: [
      courseRepositoryProvider.overrideWithValue(FakeCourseRepository()),
      courseSelectionControllerProvider.overrideWith(
        (ref) => CourseSelectionController(repository: FakeCourseRepository()),
      ),
      courseSupplementalDetailRepositoryProvider.overrideWithValue(
        FakeCourseSupplementalDetailRepository(),
      ),
      portalSessionControllerProvider.overrideWith(
        (ref) => PortalSessionController(
          authenticator: _NeverCompletingPortalAuthenticator(),
          shortcutRepository: const FakePortalShortcutRepository(),
        ),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

class FakeCourseRepository implements CourseRepository {
  @override
  Future<CourseSearchResult> searchCourses({
    String? keyword,
    String? classNo,
    String? serialNo,
    String? departmentName,
    String? collegeName,
    String? instructor,
    String? courseType,
    List<int>? credits,
    bool? hasVacancy,
    List<String>? classTimes,
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

class FakePortalAuthenticator extends PortalAuthenticator {
  FakePortalAuthenticator({this.result});

  final String? result;

  @override
  Future<String?> fetchPortalToken() async => result;
}

class FakePortalShortcutRepository implements PortalShortcutRepository {
  const FakePortalShortcutRepository();

  @override
  List<PortalShortcutSection> loadShortcutSections() {
    return const [
      PortalShortcutSection(
        title: '常用服務',
        items: [
          PortalShortcutItem(
            label: '成績查詢',
            icon: Icons.grading,
            destination: PortalWebShortcutDestination(
              title: '成績查詢',
              targetPath: '/system/incu-studentscore',
            ),
          ),
          PortalShortcutItem(
            label: 'NCU Mail',
            icon: Icons.mail,
            destination: PortalWebShortcutDestination(
              title: 'NCU Mail',
              targetPath: '/system/129',
            ),
          ),
        ],
      ),
    ];
  }
}

class FakeCourseSupplementalDetailRepository
    implements CourseSupplementalDetailRepository {
  @override
  Future<CourseSupplementalDetail?> findBySerialNo(String serialNo) async {
    return null;
  }
}

/// Returns a [Future] that never completes so [PortalSessionController.refreshSession]
/// never reaches its finally block, preventing notifyListeners() after disposal.
class _NeverCompletingPortalAuthenticator extends PortalAuthenticator {
  @override
  Future<String?> fetchPortalToken() => Completer<String?>().future;
}
