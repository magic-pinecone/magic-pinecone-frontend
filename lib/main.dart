import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_dependencies.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/core/app/app_theme.dart';
import 'package:prototype/core/navigation/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MagicPineconeApp());
}

class MagicPineconeApp extends StatefulWidget {
  const MagicPineconeApp({super.key});

  @override
  State<MagicPineconeApp> createState() => _MagicPineconeAppState();
}

class _MagicPineconeAppState extends State<MagicPineconeApp> {
  int _currentIndex = 0;
  late final AppDependencies _dependencies;

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
  void initState() {
    super.initState();
    _dependencies = AppDependencies();
  }

  @override
  void dispose() {
    _dependencies.appThemeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _dependencies.appThemeController,
      builder: (context, themeMode, _) => AppScope(
        dependencies: _dependencies,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          // Pop within the current tab first; if already at root, allow system back.
          home: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final navState = _tabKeys[_currentIndex].currentState;
              if (navState != null && navState.canPop()) {
                navState.pop();
              }
            },
            child: Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: List.generate(5, _buildTabNavigator),
              ),
              bottomNavigationBar: NavigationBar(
                onDestinationSelected: (int index) {
                  if (index == _currentIndex) {
                    // Tapping the active tab pops to its root.
                    _tabKeys[index].currentState?.popUntil((r) => r.isFirst);
                  } else {
                    setState(() => _currentIndex = index);
                  }
                },
                selectedIndex: _currentIndex,
                destinations: _destinations,
              ),
            ),
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
      onGenerateRoute: (_) => AppRoutes.tabRoot(tabs[index]),
    );
  }
}
