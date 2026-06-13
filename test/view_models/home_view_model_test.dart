import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/home/domain/models/home_dashboard_models.dart';
import 'package:magic_pinecone/features/home/domain/repository/home_dashboard_repository.dart';
import 'package:magic_pinecone/features/home/presentation/view_models/home_view_model.dart';

void main() {
  test('HomeViewModel exposes dashboard snapshot from repository', () {
    final container = ProviderContainer(
      overrides: [
        homeDashboardRepositoryProvider.overrideWithValue(
          const FakeHomeDashboardRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = container.read(homeViewModelProvider);

    expect(snapshot.coursePreviews, hasLength(1));
    expect(snapshot.coursePreviews.first.courseName, '計算機概論 I');
    expect(snapshot.shortcuts, hasLength(1));
    expect(snapshot.shortcuts.first.label, '校務系統');
    expect(snapshot.quickActionRows, hasLength(1));
    expect(snapshot.quickActionRows.first.first.label, '成績查詢');
  });
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
        ],
      ],
    );
  }
}
