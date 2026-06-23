import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_session_client.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_shortcut_repository.dart';
import 'package:magic_pinecone/features/portal/portal_providers.dart';
import 'package:magic_pinecone/features/portal/presentation/portal_page.dart';

void main() {
  testWidgets('PortalPage applies the initial shortcut search filter', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalSessionClientProvider.overrideWithValue(
            FakePortalSessionClient(result: '   '),
          ),
          portalShortcutRepositoryProvider.overrideWithValue(
            const FakePortalShortcutRepository(),
          ),
        ],
        child: const MaterialApp(home: PortalPage(initialSearchQuery: '成績')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('校務系統'), findsOneWidget);
    expect(find.text('成績查詢'), findsOneWidget);
    expect(find.text('NCU Mail'), findsNothing);
  });
}

class FakePortalSessionClient implements PortalSessionClient {
  FakePortalSessionClient({this.result});

  final String? result;

  @override
  Future<String?> refreshToken() async => result;
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
