import 'package:flutter/material.dart';

sealed class HomeActionDestination {
  const HomeActionDestination();
}

class HomeCourseSelectionDestination extends HomeActionDestination {
  const HomeCourseSelectionDestination();
}

class HomePortalDestination extends HomeActionDestination {
  const HomePortalDestination({this.initialSearchQuery});

  final String? initialSearchQuery;
}

class HomeCoursePreview {
  const HomeCoursePreview({
    required this.courseName,
    required this.courseTime,
    required this.courseLocation,
    this.category = '必修',
  });

  final String courseName;
  final String courseTime;
  final String courseLocation;
  final String category;
}

class HomeShortcutItem {
  const HomeShortcutItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

class HomeQuickActionItem {
  const HomeQuickActionItem({
    required this.icon,
    required this.label,
    required this.destination,
  });

  final IconData icon;
  final String label;
  final HomeActionDestination destination;
}

class HomeDashboardSnapshot {
  const HomeDashboardSnapshot({
    required this.coursePreviews,
    required this.shortcuts,
    required this.quickActionRows,
  });

  final List<HomeCoursePreview> coursePreviews;
  final List<HomeShortcutItem> shortcuts;
  final List<List<HomeQuickActionItem>> quickActionRows;
}
