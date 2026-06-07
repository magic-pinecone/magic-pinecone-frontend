import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/app/app_providers.dart';
import 'package:prototype/features/portal/data/portal_authenticator.dart';
import 'package:prototype/features/portal/data/portal_shortcut_repository.dart';
import 'package:prototype/features/portal/models/portal_shortcut.dart';
import 'package:prototype/features/portal/presentation/portal_page.dart';
import 'package:prototype/features/portal/presentation/view_models/portal_session_controller.dart';

void main() {
  testWidgets('PortalPage applies the initial shortcut search filter', (
    tester,
  ) async {
    final controller = PortalSessionController(
      authenticator: FakePortalAuthenticator(result: '   '),
      shortcutRepository: const FakePortalShortcutRepository(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalSessionControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          home: PortalPage(
            sessionController: controller,
            initialSearchQuery: '成績',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('校務系統'), findsOneWidget);
    expect(find.text('成績查詢'), findsOneWidget);
    expect(find.text('NCU Mail'), findsNothing);
  });
}

class FakePortalAuthenticator extends PortalAuthenticator {
  FakePortalAuthenticator({this.result});

  final String? result;

  @override
  Future<String?> fetchPortalToken() async => result;
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
