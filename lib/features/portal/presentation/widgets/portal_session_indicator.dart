import 'package:flutter/material.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_session_state.dart';
import 'package:magic_pinecone/features/portal/presentation/view_models/portal_session_controller.dart';

enum _SessionAction { refresh, login }

class PortalSessionIndicator extends StatelessWidget {
  const PortalSessionIndicator({
    super.key,
    required this.controller,
    required this.onRefresh,
    required this.onOpenLogin,
  });

  final PortalSessionController controller;
  final VoidCallback onRefresh;
  final VoidCallback onOpenLogin;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final status = controller.state.status;
        final colorScheme = Theme.of(context).colorScheme;

        final (icon, color, tooltip) = switch (status) {
          PortalSessionStatus.authenticated => (
            Icons.verified_user,
            colorScheme.primary,
            'Portal 已登入',
          ),
          PortalSessionStatus.authenticating => (
            Icons.sync,
            colorScheme.secondary,
            '驗證 Portal 中',
          ),
          PortalSessionStatus.requireReauthentication => (
            Icons.warning_amber_rounded,
            colorScheme.error,
            'Portal 需要重新登入',
          ),
          PortalSessionStatus.expired => (
            Icons.schedule,
            colorScheme.error,
            'Portal 已過期',
          ),
          PortalSessionStatus.error => (
            Icons.error_outline,
            colorScheme.error,
            'Portal 驗證失敗',
          ),
        };

        return PopupMenuButton<_SessionAction>(
          tooltip: tooltip,
          onSelected: (value) {
            switch (value) {
              case _SessionAction.refresh:
                onRefresh();
                break;
              case _SessionAction.login:
                onOpenLogin();
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: _SessionAction.refresh, child: Text('重新驗證')),
            PopupMenuItem(
              value: _SessionAction.login,
              child: Text('前往 Portal 登入'),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(icon, color: color),
          ),
        );
      },
    );
  }
}
