import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/portal/models/portal_shortcut.dart';
import 'package:prototype/features/portal/presentation/portal_shortcuts_page.dart';

void main() {
  testWidgets('PortalShortcutsPage filters shortcuts case-insensitively', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PortalShortcutsPage(
          sections: _shortcutSections,
          onShortcutTap: (_) {},
        ),
      ),
    );

    await tester.enterText(find.byType(SearchBar), 'MAIL');
    await tester.pump();

    expect(find.text('NCU Mail'), findsOneWidget);
    expect(find.text('成績查詢'), findsNothing);
    expect(find.text('常用服務'), findsOneWidget);
    expect(find.text('找不到相關功能'), findsNothing);
  });

  testWidgets('PortalShortcutsPage shows empty state when nothing matches', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PortalShortcutsPage(
          sections: _shortcutSections,
          initialSearchQuery: 'library',
          onShortcutTap: (_) {},
        ),
      ),
    );

    expect(find.text('找不到相關功能'), findsOneWidget);
    expect(find.text('成績查詢'), findsNothing);
    expect(find.text('NCU Mail'), findsNothing);
  });

  testWidgets('PortalShortcutsPage reports the tapped shortcut item', (
    tester,
  ) async {
    PortalShortcutItem? tappedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: PortalShortcutsPage(
          sections: _shortcutSections,
          onShortcutTap: (item) => tappedItem = item,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.grading));
    await tester.pump();

    expect(tappedItem?.label, '成績查詢');
  });
}

const _shortcutSections = [
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
