import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/core/navigation/app_routes.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/presentation/portal_shortcuts_page.dart';
import 'package:magic_pinecone/features/portal/presentation/view_models/portal_session_controller.dart';
import 'package:magic_pinecone/features/portal/presentation/widgets/portal_session_indicator.dart';

class PortalPage extends StatelessWidget {
  const PortalPage({
    super.key,
    this.sessionController,
    this.initialSearchQuery = '',
  });

  final PortalSessionController? sessionController;
  final String initialSearchQuery;

  @override
  Widget build(BuildContext context) {
    final hasScope =
        context.findAncestorWidgetOfExactType<ProviderScope>() != null ||
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() !=
            null;

    final child = _PortalPageInner(
      sessionController: sessionController,
      initialSearchQuery: initialSearchQuery,
    );

    if (hasScope) {
      return child;
    } else {
      return ProviderScope(child: child);
    }
  }
}

class _PortalPageInner extends ConsumerStatefulWidget {
  const _PortalPageInner({
    this.sessionController,
    this.initialSearchQuery = '',
  });

  final PortalSessionController? sessionController;
  final String initialSearchQuery;

  @override
  ConsumerState<_PortalPageInner> createState() => _PortalPageInnerState();
}

class _PortalPageInnerState extends ConsumerState<_PortalPageInner> {
  late final PortalSessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.sessionController ?? ref.read(portalSessionControllerProvider);
    scheduleMicrotask(() {
      if (mounted) {
        unawaited(_controller.refreshSession());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sessionController == null) {
      ref.watch(portalSessionControllerProvider);
    }
    return _PortalPageContent(
      sessionController: _controller,
      initialSearchQuery: widget.initialSearchQuery,
    );
  }
}

class _PortalPageContent extends StatelessWidget {
  const _PortalPageContent({
    required this.sessionController,
    required this.initialSearchQuery,
  });

  static const _portalAuthHost = 'portal.ncu.edu.tw';

  final PortalSessionController sessionController;
  final String initialSearchQuery;

  @override
  Widget build(BuildContext context) {
    return PortalShortcutsPage(
      sections: sessionController.shortcutSections,
      initialSearchQuery: initialSearchQuery,
      appBarActions: [
        PortalSessionIndicator(
          controller: sessionController,
          onRefresh: () => unawaited(_refreshPortalAuth()),
          onOpenLogin: () => unawaited(_openPortalLogin(context)),
        ),
      ],
      onShortcutTap: (item) => unawaited(_openShortcut(context, item)),
    );
  }

  Future<void> _refreshPortalAuth() async {
    await sessionController.refreshSession();
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

  Future<void> _openShortcut(BuildContext context, PortalShortcutItem item) {
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
          token: destination.openExternally
              ? sessionController.state.token
              : null,
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
    await sessionController.refreshSession();
  }
}
