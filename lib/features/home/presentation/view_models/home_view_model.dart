import 'package:flutter/foundation.dart';
import 'package:magic_pinecone/features/home/domain/models/home_dashboard_models.dart';
import 'package:magic_pinecone/features/home/domain/repository/home_dashboard_repository.dart';

// TODO: Migrate this controller from ChangeNotifier to a modern Riverpod Notifier/AsyncNotifier
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required HomeDashboardRepository repository}) {
    final dashboard = repository.loadDashboard();
    _coursePreviews = List.unmodifiable(dashboard.coursePreviews);
    _shortcuts = List.unmodifiable(dashboard.shortcuts);
    _quickActionRows = dashboard.quickActionRows
        .map(List<HomeQuickActionItem>.unmodifiable)
        .toList(growable: false);
  }

  late final List<HomeCoursePreview> _coursePreviews;
  late final List<HomeShortcutItem> _shortcuts;
  late final List<List<HomeQuickActionItem>> _quickActionRows;

  List<HomeCoursePreview> get coursePreviews => _coursePreviews;
  List<HomeShortcutItem> get shortcuts => _shortcuts;
  List<List<HomeQuickActionItem>> get quickActionRows => _quickActionRows;
}
