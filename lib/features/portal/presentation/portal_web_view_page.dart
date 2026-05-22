import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

typedef SessionProbeCallback =
    Future<void> Function(InAppWebViewController controller, Uri currentUrl);

class PortalWebViewPage extends StatefulWidget {
  const PortalWebViewPage({
    super.key,
    required this.title,
    required this.targetUrl,
    this.authEntryUrl,
    this.onNavigationChanged,
    this.onSessionProbe,
    this.sessionProbeHosts = const {},
  });

  final String title;
  final Uri targetUrl;
  final Uri? authEntryUrl;
  final ValueChanged<Uri>? onNavigationChanged;
  final SessionProbeCallback? onSessionProbe;
  final Set<String> sessionProbeHosts;

  @override
  State<PortalWebViewPage> createState() => _PortalWebViewPageState();
}

class _PortalWebViewPageState extends State<PortalWebViewPage> {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.blue),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          _webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          _webViewController?.loadUrl(
            urlRequest: URLRequest(url: await _webViewController?.getUrl()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新整理',
            onPressed: () => _webViewController?.reload(),
          ),
          if (widget.authEntryUrl != null)
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: '前往 Portal 登入',
              onPressed: _goToAuthEntry,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(value: _progress / 100.0),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri.uri(widget.targetUrl)),
              pullToRefreshController: _pullToRefreshController,
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                useOnDownloadStart: true,
                isInspectable: kDebugMode,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                _handlePageEvent(url);
              },
              onLoadStop: (controller, url) {
                _pullToRefreshController?.endRefreshing();
                _handlePageEvent(url);
              },
              onUpdateVisitedHistory: (controller, url, _) {
                _handlePageEvent(url);
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  _pullToRefreshController?.endRefreshing();
                }
                if (!mounted) return;
                setState(() => _progress = progress);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _goToAuthEntry() {
    final authEntryUrl = widget.authEntryUrl;
    final webViewController = _webViewController;
    if (authEntryUrl == null || webViewController == null) return;

    webViewController.loadUrl(
      urlRequest: URLRequest(url: WebUri.uri(authEntryUrl)),
    );
  }

  void _handlePageEvent(Uri? currentUrl) {
    if (currentUrl == null) return;
    widget.onNavigationChanged?.call(currentUrl);

    final sessionProbe = widget.onSessionProbe;
    if (sessionProbe == null || _webViewController == null) return;

    if (widget.sessionProbeHosts.isNotEmpty &&
        !widget.sessionProbeHosts.contains(currentUrl.host)) {
      return;
    }

    unawaited(sessionProbe(_webViewController!, currentUrl));
  }
}
