import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/core/navigation/app_routes.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_page.dart';
import 'package:magic_pinecone/features/home/presentation/home_page.dart';
import 'package:magic_pinecone/features/news/presentation/news_page.dart';
import 'package:magic_pinecone/features/portal/presentation/portal_page.dart';
import 'package:magic_pinecone/features/settings/presentation/settings_page.dart';

void main() {
  test('AppRoutes maps each root tab to the expected page', () {
    expect(AppRoutes.buildTabPage(AppTab.home), isA<HomePage>());
    expect(AppRoutes.buildTabPage(AppTab.news), isA<NewsPage>());
    expect(AppRoutes.buildTabPage(AppTab.portal), isA<PortalPage>());
    expect(
      AppRoutes.buildTabPage(AppTab.courseSelection),
      isA<CourseSelectionPage>(),
    );
    expect(AppRoutes.buildTabPage(AppTab.settings), isA<SettingsPage>());
  });

  test('AppRoutes forwards share code to course selection tab', () {
    final page = AppRoutes.buildTabPage(
      AppTab.courseSelection,
      initialShareCode: 'abc123',
    );

    expect(page, isA<CourseSelectionPage>());
    expect((page as CourseSelectionPage).initialShareCode, 'abc123');
  });

  test('AppRoutes exposes stable route names for major flows', () {
    expect(AppRoutes.tabRoot(AppTab.portal).settings.name, 'tab/portal');
    expect(AppRoutes.courseSelection<void>().settings.name, 'course-selection');
    expect(AppRoutes.portal<void>().settings.name, 'portal');
    expect(
      AppRoutes.portal<void>(initialSearchQuery: '成績查詢').settings.name,
      'portal/search',
    );
  });
}
