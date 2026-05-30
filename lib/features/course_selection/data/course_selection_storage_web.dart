import 'dart:js_interop';

import 'package:prototype/features/course_selection/data/course_selection_storage.dart';

@JS('window.localStorage.getItem')
external JSString? _getLocalStorageItem(JSString key);

@JS('window.localStorage.setItem')
external void _setLocalStorageItem(JSString key, JSString value);

@JS('window.localStorage.removeItem')
external void _removeLocalStorageItem(JSString key);

class PlatformCourseSelectionStorage implements CourseSelectionStorage {
  static const _shareCodeKey = 'magic_pinecone.course_selection.share_code';

  @override
  Future<String?> readShareCode() async {
    return _getLocalStorageItem(_shareCodeKey.toJS)?.toDart;
  }

  @override
  Future<void> writeShareCode(String code) async {
    _setLocalStorageItem(_shareCodeKey.toJS, code.toJS);
  }

  @override
  Future<void> clearShareCode() async {
    _removeLocalStorageItem(_shareCodeKey.toJS);
  }
}
