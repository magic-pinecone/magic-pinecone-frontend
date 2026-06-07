import 'package:flutter/foundation.dart';
import 'package:prototype/features/portal/data/portal_authenticator.dart';
import 'package:prototype/features/portal/data/portal_shortcut_repository.dart';
import 'package:prototype/features/portal/models/portal_session_state.dart';
import 'package:prototype/features/portal/models/portal_shortcut.dart';

class PortalSessionController extends ChangeNotifier {
  PortalSessionController({
    required this.authenticator,
    required PortalShortcutRepository shortcutRepository,
  }) : _shortcutSections = List.unmodifiable(
         shortcutRepository.loadShortcutSections(),
       );

  final PortalAuthenticator authenticator;
  final List<PortalShortcutSection> _shortcutSections;

  PortalSessionState _state = const PortalSessionState.expired();
  Future<String?>? _refreshing;

  PortalSessionState get state => _state;
  List<PortalShortcutSection> get shortcutSections => _shortcutSections;

  Future<String?> refreshSession() {
    if (_refreshing != null) {
      return _refreshing!;
    }

    _state = _state.copyWith(status: PortalSessionStatus.authenticating);
    notifyListeners();

    _refreshing = _refreshSessionInternal();
    return _refreshing!;
  }

  void markReauthenticationRequired() {
    _state = _state.copyWith(
      status: PortalSessionStatus.requireReauthentication,
      clearToken: true,
    );
    notifyListeners();
  }

  Future<String?> _refreshSessionInternal() async {
    try {
      final token = await authenticator.fetchPortalToken();
      final normalizedToken = token?.trim();

      if (normalizedToken != null && normalizedToken.isNotEmpty) {
        _state = PortalSessionState(
          status: PortalSessionStatus.authenticated,
          token: normalizedToken,
        );
      } else {
        _state = const PortalSessionState.expired();
      }

      return normalizedToken;
    } catch (_) {
      _state = _state.copyWith(
        status: PortalSessionStatus.error,
        clearToken: true,
      );
      return null;
    } finally {
      _refreshing = null;
      notifyListeners();
    }
  }
}
