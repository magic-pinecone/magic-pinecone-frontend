import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/portal/data/data_sources/portal_authenticator.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_session_state.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_shortcut_repository.dart';
import 'package:magic_pinecone/features/portal/portal_providers.dart';
import 'package:magic_pinecone/features/portal/presentation/view_models/portal_session_controller.dart';

void main() {
  group('PortalSessionController', () {
    test(
      'stores authenticated state when authenticator returns token',
      () async {
        final container = ProviderContainer(
          overrides: [
            portalAuthenticatorProvider.overrideWithValue(
              FakePortalAuthenticator(result: ' token123 '),
            ),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          portalSessionControllerProvider.notifier,
        );
        final token = await controller.refreshSession();

        final state = container.read(portalSessionControllerProvider);
        expect(token, 'token123');
        expect(state.status, PortalSessionStatus.authenticated);
        expect(state.token, 'token123');
        expect(state.isAuthenticated, isTrue);
      },
    );

    test('stores expired state when authenticator returns no token', () async {
      final container = ProviderContainer(
        overrides: [
          portalAuthenticatorProvider.overrideWithValue(
            FakePortalAuthenticator(result: '   '),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        portalSessionControllerProvider.notifier,
      );
      await controller.refreshSession();

      final state = container.read(portalSessionControllerProvider);
      expect(state.status, PortalSessionStatus.expired);
      expect(state.token, isNull);
    });

    test('stores error state when authenticator throws', () async {
      final container = ProviderContainer(
        overrides: [
          portalAuthenticatorProvider.overrideWithValue(
            FakePortalAuthenticator(error: StateError('boom')),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        portalSessionControllerProvider.notifier,
      );
      await controller.refreshSession();

      final state = container.read(portalSessionControllerProvider);
      expect(state.status, PortalSessionStatus.error);
      expect(state.token, isNull);
    });

    test('marks reauthentication as required and clears token', () async {
      final container = ProviderContainer(
        overrides: [
          portalAuthenticatorProvider.overrideWithValue(
            FakePortalAuthenticator(result: 'token123'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        portalSessionControllerProvider.notifier,
      );
      await controller.refreshSession();

      controller.markReauthenticationRequired();

      final state = container.read(portalSessionControllerProvider);
      expect(state.status, PortalSessionStatus.requireReauthentication);
      expect(state.token, isNull);
    });

    test('exposes shortcut sections from repository', () {
      final container = ProviderContainer(
        overrides: [
          portalShortcutRepositoryProvider.overrideWithValue(
            const FakePortalShortcutRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sections = container.read(portalShortcutSectionsProvider);
      expect(sections, hasLength(1));
      expect(sections.first.title, '常用服務');
      expect(sections.first.items.first.label, '成績查詢');
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
