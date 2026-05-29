import 'package:flutter/material.dart';

const portalHost = 'portal.ncu.edu.tw';

class PortalShortcutSection {
  const PortalShortcutSection({required this.title, required this.items});

  final String title;
  final List<PortalShortcutItem> items;
}

class PortalShortcutItem {
  const PortalShortcutItem({
    required this.label,
    required this.icon,
    required this.destination,
  });

  final String label;
  final IconData icon;
  final PortalShortcutDestination destination;
}

sealed class PortalShortcutDestination {
  const PortalShortcutDestination();
}

class PortalInternalShortcutDestination extends PortalShortcutDestination {
  const PortalInternalShortcutDestination({required this.pageBuilder});

  final WidgetBuilder pageBuilder;
}

class PortalWebShortcutDestination extends PortalShortcutDestination {
  const PortalWebShortcutDestination({
    required this.title,
    this.targetPath,
    this.targetUrl,
    this.openExternally = false,
    this.authEntryUrl,
    this.sessionProbeHosts = const {},
  });

  final String title;
  final String? targetPath;
  final Uri? targetUrl;
  final bool openExternally;
  final Uri? authEntryUrl;
  final Set<String> sessionProbeHosts;

  Uri? buildTargetUrl({String? token}) {
    final targetUrl = this.targetUrl;
    if (targetUrl != null) return targetUrl;

    final targetPath = this.targetPath;
    if (targetPath == null) return null;

    final normalizedToken = token?.trim();
    final queryParameters = <String, String>{};
    if (normalizedToken != null && normalizedToken.isNotEmpty) {
      queryParameters['token'] = normalizedToken;
    }

    return Uri(
      scheme: 'https',
      host: portalHost,
      path: targetPath.startsWith('/') ? targetPath.substring(1) : targetPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }
}
