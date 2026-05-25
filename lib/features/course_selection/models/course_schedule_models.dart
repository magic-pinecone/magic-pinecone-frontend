class CourseSearchResult {
  const CourseSearchResult({
    required this.totalCount,
    required this.courses,
    this.lastUpdated,
  });

  final int totalCount;
  final DateTime? lastUpdated;
  final List<CourseItem> courses;
}

class CourseItem {
  const CourseItem({
    required this.serialNo,
    required this.classNo,
    required this.title,
    required this.credit,
    required this.teachers,
    required this.classTimes,
    this.passwordCard,
    this.limitCount,
    this.admitCount,
    this.waitCount,
    this.collegeId,
    this.departmentId,
    this.courseType,
  });

  final String serialNo;
  final String classNo;
  final String title;
  final int credit;
  final String? passwordCard;
  final List<String> teachers;
  final List<String> classTimes;
  final int? limitCount;
  final int? admitCount;
  final int? waitCount;
  final String? collegeId;
  final String? departmentId;
  final String? courseType;

  String get teacherText => teachers.isEmpty ? '未定' : teachers.join('、');

  String get classTimeText =>
      classTimes.isEmpty ? '時間未定' : classTimes.join('、');

  String get creditText => credit.toString();

  String get courseTypeText {
    return switch (courseType) {
      'REQUIRED' => '必修',
      'ELECTIVE' => '選修',
      final value? when value.isNotEmpty => value,
      _ => '未分類',
    };
  }

  String get enrollmentText {
    final admitted = admitCount;
    final limit = limitCount;
    final waiting = waitCount;

    if (admitted == null && limit == null && waiting == null) {
      return '人數未定';
    }

    final base = switch ((admitted, limit)) {
      (final admitted?, final limit?) => '$admitted / $limit',
      (final admitted?, null) => '已選 $admitted',
      (null, final limit?) => '上限 $limit',
      _ => '',
    };

    if (waiting == null || waiting == 0) return base;
    if (base.isEmpty) return '候補 $waiting';
    return '$base · 候補 $waiting';
  }
}

class ScheduledCourse {
  const ScheduledCourse({
    required this.name,
    required this.dayIndex,
    required this.startPeriodIndex,
    required this.length,
    required this.location,
    this.category = '必修',
  });

  final String name;
  final int dayIndex;
  final int startPeriodIndex;
  final int length;
  final String location;
  final String category;
}

class CourseScheduleSnapshot {
  const CourseScheduleSnapshot({
    required this.courses,
    required this.weekDays,
    required this.periods,
  });

  final List<ScheduledCourse> courses;
  final List<String> weekDays;
  final List<String> periods;
}
