import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/portal/data/portal_authenticator.dart';
import 'package:magic_pinecone/features/portal/data/portal_shortcut_repository.dart';
import 'package:magic_pinecone/features/portal/models/portal_session_state.dart';
import 'package:magic_pinecone/features/portal/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/presentation/view_models/portal_session_controller.dart';

void main() {
  group('PortalSessionController', () {
    test(
      'stores authenticated state when authenticator returns token',
      () async {
        final controller = PortalSessionController(
          authenticator: FakePortalAuthenticator(result: ' token123 '),
          shortcutRepository: const FakePortalShortcutRepository(),
        );

        final token = await controller.refreshSession();

        expect(token, 'token123');
        expect(controller.state.status, PortalSessionStatus.authenticated);
        expect(controller.state.token, 'token123');
        expect(controller.state.isAuthenticated, isTrue);
      },
    );

    test('stores expired state when authenticator returns no token', () async {
      final controller = PortalSessionController(
        authenticator: FakePortalAuthenticator(result: '   '),
        shortcutRepository: const FakePortalShortcutRepository(),
      );

      await controller.refreshSession();

      expect(controller.state.status, PortalSessionStatus.expired);
      expect(controller.state.token, isNull);
    });

    test('stores error state when authenticator throws', () async {
      final controller = PortalSessionController(
        authenticator: FakePortalAuthenticator(error: StateError('boom')),
        shortcutRepository: const FakePortalShortcutRepository(),
      );

      await controller.refreshSession();

      expect(controller.state.status, PortalSessionStatus.error);
      expect(controller.state.token, isNull);
    });

    test('marks reauthentication as required and clears token', () async {
      final controller = PortalSessionController(
        authenticator: FakePortalAuthenticator(result: 'token123'),
        shortcutRepository: const FakePortalShortcutRepository(),
      );
      await controller.refreshSession();

      controller.markReauthenticationRequired();

      expect(
        controller.state.status,
        PortalSessionStatus.requireReauthentication,
      );
      expect(controller.state.token, isNull);
    });

    test('exposes shortcut sections from repository', () {
      final controller = PortalSessionController(
        authenticator: FakePortalAuthenticator(result: 'token123'),
        shortcutRepository: const FakePortalShortcutRepository(),
      );

      expect(controller.shortcutSections, hasLength(1));
      expect(controller.shortcutSections.first.title, '常用服務');
      expect(controller.shortcutSections.first.items.first.label, '成績查詢');
    });
  });
}

class FakePortalAuthenticator extends PortalAuthenticator {
  FakePortalAuthenticator({this.result, this.error});

  final String? result;
  final Object? error;

  @override
  Future<String?> fetchPortalToken() async {
    if (error != null) {
      throw error!;
    }
    return result;
  }
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
        ],
      ),
    ];
  }
}
