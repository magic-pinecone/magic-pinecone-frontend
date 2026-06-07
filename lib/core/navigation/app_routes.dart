import 'package:flutter/material.dart';
import 'package:magic_pinecone/features/course_selection/presentation/course_selection_page.dart';
import 'package:magic_pinecone/features/home/presentation/home_page.dart';
import 'package:magic_pinecone/features/news/presentation/news_page.dart';
import 'package:magic_pinecone/features/portal/presentation/portal_page.dart';
import 'package:magic_pinecone/features/portal/presentation/portal_web_view_page.dart';
import 'package:magic_pinecone/features/settings/presentation/settings_page.dart';

enum AppTab { home, news, portal, courseSelection, settings }

class AppRoutes {
  const AppRoutes._();

  static Route<void> tabRoot(AppTab tab, {String? initialShareCode}) {
    return MaterialPageRoute<void>(
      builder: (_) => buildTabPage(tab, initialShareCode: initialShareCode),
      settings: RouteSettings(name: 'tab/${tab.name}'),
    );
  }

  static Widget buildTabPage(AppTab tab, {String? initialShareCode}) {
    return switch (tab) {
      AppTab.home => const HomePage(),
      AppTab.news => const NewsPage(),
      AppTab.portal => const PortalPage(),
      AppTab.courseSelection => CourseSelectionPage(
        initialShareCode: initialShareCode,
      ),
      AppTab.settings => const SettingsPage(),
    };
  }

  static Route<T> courseSelection<T>({String? initialShareCode}) {
    return MaterialPageRoute<T>(
      builder: (_) => CourseSelectionPage(
        showBackButton: true,
        initialShareCode: initialShareCode,
      ),
      settings: const RouteSettings(name: 'course-selection'),
    );
  }

  static Route<T> portal<T>({String initialSearchQuery = ''}) {
    return MaterialPageRoute<T>(
      builder: (_) => PortalPage(initialSearchQuery: initialSearchQuery),
      settings: RouteSettings(
        name: initialSearchQuery.isEmpty ? 'portal' : 'portal/search',
      ),
    );
  }

  static Route<void> portalWebView({
    required String title,
    required Uri targetUrl,
    Uri? authEntryUrl,
    ValueChanged<Uri>? onNavigationChanged,
    SessionProbeCallback? onSessionProbe,
    Set<String> sessionProbeHosts = const {},
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => PortalWebViewPage(
        title: title,
        targetUrl: targetUrl,
        authEntryUrl: authEntryUrl,
        onNavigationChanged: onNavigationChanged,
        onSessionProbe: onSessionProbe,
        sessionProbeHosts: sessionProbeHosts,
      ),
      settings: RouteSettings(name: 'portal/web/$title'),
    );
  }

  static Route<T> widget<T>({required WidgetBuilder builder, String? name}) {
    return MaterialPageRoute<T>(
      builder: builder,
      settings: RouteSettings(name: name),
    );
  }
}

extension AppNavigator on BuildContext {
  Future<T?> pushCourseSelection<T>() {
    return Navigator.of(this).push<T>(AppRoutes.courseSelection());
  }

  Future<T?> pushPortal<T>({String initialSearchQuery = ''}) {
    return Navigator.of(
      this,
    ).push<T>(AppRoutes.portal(initialSearchQuery: initialSearchQuery));
  }
}
