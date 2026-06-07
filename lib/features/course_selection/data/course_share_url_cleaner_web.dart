import 'dart:js_interop';

import 'package:prototype/features/course_selection/data/course_share_url.dart';

@JS('window.history.replaceState')
external void _replaceBrowserHistoryState(
  JSAny? data,
  JSString title,
  JSString url,
);

void clearPlatformCourseShareCodeFromBrowserUrl() {
  final currentUri = Uri.base;
  if (!currentUri.queryParameters.containsKey('c')) return;

  final cleanUri = removeCourseShareCode(currentUri);
  _replaceBrowserHistoryState(null, ''.toJS, cleanUri.toString().toJS);
}
