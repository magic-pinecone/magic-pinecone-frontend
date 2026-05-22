import 'package:flutter/material.dart';
import 'package:prototype/features/home/models/home_dashboard_models.dart';

const homeCoursePreviews = [
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
];

const homeShortcutItems = [
  HomeShortcutItem(icon: Icons.school, label: '校務系統', color: Color(0xFF4A90D9)),
  HomeShortcutItem(
    icon: Icons.calendar_today,
    label: '行事曆',
    color: Color(0xFFE57373),
  ),
  HomeShortcutItem(
    icon: Icons.mail_outline,
    label: '信箱',
    color: Color(0xFF66BB6A),
  ),
  HomeShortcutItem(
    icon: Icons.library_books,
    label: '圖書館',
    color: Color(0xFFFF9800),
  ),
];

const homeQuickActionRows = [
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
  [
    HomeQuickActionItem(
      icon: Icons.book_outlined,
      label: '課程查詢',
      destination: HomeCourseSelectionDestination(),
    ),
    HomeQuickActionItem(
      icon: Icons.mail_outline,
      label: '校園信箱',
      destination: HomePortalDestination(initialSearchQuery: 'NCU Mail'),
    ),
  ],
  [
    HomeQuickActionItem(
      icon: Icons.receipt_long,
      label: '繳費資訊',
      destination: HomePortalDestination(initialSearchQuery: '學費'),
    ),
    HomeQuickActionItem(
      icon: Icons.support_agent,
      label: '服務櫃台',
      destination: HomePortalDestination(initialSearchQuery: '服務櫃台'),
    ),
  ],
];
