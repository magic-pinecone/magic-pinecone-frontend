import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/core/navigation/app_routes.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/presentation/portal_shortcuts_page.dart';
import 'package:magic_pinecone/features/portal/presentation/view_models/portal_session_controller.dart';
import 'package:magic_pinecone/features/portal/presentation/widgets/portal_session_indicator.dart';

class PortalPage extends ConsumerStatefulWidget {
  const PortalPage({super.key, this.initialSearchQuery = ''});

  final String initialSearchQuery;

  @override
  ConsumerState<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends ConsumerState<PortalPage> {
  static const _portalAuthHost = 'portal.ncu.edu.tw';

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (mounted) {
        unawaited(
          ref.read(portalSessionControllerProvider.notifier).refreshSession(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(portalSessionControllerProvider);
    final shortcutSections = ref.watch(portalShortcutSectionsProvider);

    return PortalShortcutsPage(
      sections: shortcutSections,
      initialSearchQuery: widget.initialSearchQuery,
      appBarActions: [
        PortalSessionIndicator(
          sessionState: sessionState,
          onRefresh: () => unawaited(_refreshPortalAuth()),
          onOpenLogin: () => unawaited(_openPortalLogin(context)),
        ),
      ],
      onShortcutTap: (item) =>
          unawaited(_openShortcut(context, item, sessionState.token)),
    );
  }

  Future<void> _refreshPortalAuth() async {
    await ref.read(portalSessionControllerProvider.notifier).refreshSession();
  }

  Future<void> _openPortalLogin(BuildContext context) {
    return Navigator.of(context)
        .push(
          AppRoutes.portalWebView(
            title: 'Portal 登入',
            targetUrl: Uri(scheme: 'https', host: _portalAuthHost),
            authEntryUrl: Uri(scheme: 'https', host: _portalAuthHost),
            sessionProbeHosts: const {_portalAuthHost},
            onSessionProbe: _probeAuthStateFromWebView,
          ),
        )
        .then((_) => _refreshPortalAuth());
  }

  Future<void> _openShortcut(
    BuildContext context,
    PortalShortcutItem item,
    String? token,
  ) {
    final destination = item.destination;

    switch (destination) {
      case PortalInternalShortcutDestination(:final pageBuilder):
        return Navigator.of(
          context,
        ).push(AppRoutes.widget(builder: pageBuilder, name: 'portal/internal'));
      case PortalWebShortcutDestination(
        :final title,
        :final authEntryUrl,
        :final sessionProbeHosts,
      ):
        final targetUrl = destination.buildTargetUrl(
          token: destination.openExternally ? token : null,
        );
        if (targetUrl == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('此功能尚未設定連結')));
          return Future.value();
        }
        if (destination.openExternally) {
          return InAppBrowser.openWithSystemBrowser(url: WebUri.uri(targetUrl));
        }
        return Navigator.of(context).push(
          AppRoutes.portalWebView(
            title: title,
            targetUrl: targetUrl,
            authEntryUrl: authEntryUrl,
            sessionProbeHosts: sessionProbeHosts,
            onSessionProbe: _probeAuthStateFromWebView,
          ),
        );
    }
  }

  Future<void> _probeAuthStateFromWebView(
    InAppWebViewController controller,
    Uri currentUrl,
  ) async {
    if (currentUrl.host != _portalAuthHost) return;
    await ref.read(portalSessionControllerProvider.notifier).refreshSession();
  }
}
