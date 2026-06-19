import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/core/app/app_theme.dart';
import 'package:magic_pinecone/core/navigation/app_navigation_state.dart';
import 'package:magic_pinecone/core/navigation/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MagicPineconeApp());
}

AppTab initialAppTabForUri(Uri uri) {
  return courseShareCodeFromUri(uri) == null
      ? AppTab.home
      : AppTab.courseSelection;
}

String? courseShareCodeFromUri(Uri uri) {
  final shareCode = uri.queryParameters['c']?.trim();
  if (shareCode == null || shareCode.isEmpty) return null;
  return shareCode;
}

class MagicPineconeApp extends StatelessWidget {
  const MagicPineconeApp({super.key, this.initialUri});

  final Uri? initialUri;

  @override
  Widget build(BuildContext context) {
    final resolvedInitialUri = initialUri ?? Uri.base;

    return ProviderScope(
      overrides: [
        initialActiveAppTabProvider.overrideWithValue(
          initialAppTabForUri(resolvedInitialUri),
        ),
      ],
      child: _MagicPineconeAppShell(
        initialShareCode: courseShareCodeFromUri(resolvedInitialUri),
      ),
    );
  }
}

class _MagicPineconeAppShell extends ConsumerStatefulWidget {
  const _MagicPineconeAppShell({required this.initialShareCode});

  final String? initialShareCode;

  @override
  ConsumerState<_MagicPineconeAppShell> createState() =>
      _MagicPineconeAppShellState();
}

class _MagicPineconeAppShellState
    extends ConsumerState<_MagicPineconeAppShell> {
  // Each tab gets its own GlobalKey so its Navigator state is preserved.
  final _tabKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home), label: '首頁'),
    NavigationDestination(icon: Icon(Icons.campaign), label: '訊息'),
    NavigationDestination(icon: Icon(Icons.book), label: '校務系統'),
    NavigationDestination(icon: Icon(Icons.calendar_view_week), label: '選課'),
    NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeControllerProvider);
    final currentIndex = ref.watch(activeAppTabProvider).index;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Pop within the current tab first; if already at root, allow system back.
      home: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final navState = _tabKeys[currentIndex].currentState;
          if (navState != null && navState.canPop()) {
            navState.pop();
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: List.generate(5, _buildTabNavigator),
          ),
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              if (index == currentIndex) {
                // Tapping the active tab pops to its root.
                _tabKeys[index].currentState?.popUntil((r) => r.isFirst);
              } else {
                ref
                    .read(activeAppTabProvider.notifier)
                    .setTab(AppTab.values[index]);
              }
            },
            selectedIndex: currentIndex,
            destinations: _destinations,
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index) {
    const tabs = [
      AppTab.home,
      AppTab.news,
      AppTab.portal,
      AppTab.courseSelection,
      AppTab.settings,
    ];

    return Navigator(
      key: _tabKeys[index],
      onGenerateRoute: (_) => AppRoutes.tabRoot(
        tabs[index],
        initialShareCode: index == AppTab.courseSelection.index
            ? widget.initialShareCode
            : null,
      ),
    );
  }
}
