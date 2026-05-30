import 'package:prototype/features/course_selection/data/course_selection_storage_platform.dart';

abstract class CourseSelectionStorage {
  Future<String?> readShareCode();

  Future<void> writeShareCode(String code);

  Future<void> clearShareCode();
}

CourseSelectionStorage createCourseSelectionStorage() {
  return PlatformCourseSelectionStorage();
}

class MemoryCourseSelectionStorage implements CourseSelectionStorage {
  String? _shareCode;

  @override
  Future<String?> readShareCode() async => _shareCode;

  @override
  Future<void> writeShareCode(String code) async {
    _shareCode = code;
  }

  @override
  Future<void> clearShareCode() async {
    _shareCode = null;
  }
}
