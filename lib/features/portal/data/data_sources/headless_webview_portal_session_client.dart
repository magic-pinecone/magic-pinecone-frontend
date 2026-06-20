import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_session_client.dart';

class HeadlessWebViewPortalSessionClient implements PortalSessionClient {
  HeadlessInAppWebView? _headless;
  Future<String?>? _fetching;

  HeadlessWebViewPortalSessionClient();

  @override
  Future<String?> refreshToken() async {
    if (_fetching != null) {
      return _fetching!;
    }
    _fetching = _refreshTokenInternal();
    return _fetching!;
  }

  Future<String?> _refreshTokenInternal() async {
    final completer = Completer<String?>();

    _headless = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri.uri(Uri.parse("https://portal.ncu.edu.tw")),
      ),
      initialSettings: InAppWebViewSettings(),
      onLoadStop: (controller, url) async {
        // Assuming the portal sets a global JS variable `window.token` upon successful login
        final token = await controller.evaluateJavascript(
          source: "window.token;",
        );
        if (!completer.isCompleted) {
          completer.complete(token?.toString());
        }
      },
    );

    try {
      await _headless!.run();

      // 30s timeout to prevent hanging indefinitely
      final result = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint("Portal auth timed out");
          return null;
        },
      );

      final token = result?.trim();
      return token;
    } catch (e) {
      debugPrint("Error occurred during fetching portal token: $e");
      return null;
    } finally {
      await _headless?.dispose();
      _headless = null;
      _fetching = null;
    }
  }
}
