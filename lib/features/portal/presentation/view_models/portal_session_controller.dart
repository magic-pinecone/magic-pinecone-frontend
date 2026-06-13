import 'package:magic_pinecone/features/portal/domain/models/portal_session_state.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/domain/usecases/load_portal_shortcuts_use_case.dart';
import 'package:magic_pinecone/features/portal/domain/usecases/refresh_portal_session_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'portal_session_controller.g.dart';

@riverpod
List<PortalShortcutSection> portalShortcutSections(Ref ref) {
  return ref.watch(loadPortalShortcutsUseCaseProvider).execute();
}

@riverpod
class PortalSessionController extends _$PortalSessionController {
  Future<String?>? _refreshing;

  @override
  PortalSessionState build() {
    return const PortalSessionState.expired();
  }

  Future<String?> refreshSession() {
    if (_refreshing != null) {
      return _refreshing!;
    }

    state = state.copyWith(status: PortalSessionStatus.authenticating);
    _refreshing = _refreshSessionInternal();
    return _refreshing!;
  }

  void markReauthenticationRequired() {
    state = state.copyWith(
      status: PortalSessionStatus.requireReauthentication,
      clearToken: true,
    );
  }

  Future<String?> _refreshSessionInternal() async {
    try {
      final token = await ref
          .read(refreshPortalSessionUseCaseProvider)
          .execute();
      final normalizedToken = token?.trim();

      if (normalizedToken != null && normalizedToken.isNotEmpty) {
        state = PortalSessionState(
          status: PortalSessionStatus.authenticated,
          token: normalizedToken,
        );
      } else {
        state = const PortalSessionState.expired();
      }

      return normalizedToken;
    } catch (_) {
      state = state.copyWith(
        status: PortalSessionStatus.error,
        clearToken: true,
      );
      return null;
    } finally {
      _refreshing = null;
    }
  }
}
