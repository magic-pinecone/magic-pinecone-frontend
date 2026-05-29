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
    this.collegeName,
    this.departmentName,
    this.courseType,
  });

  final String detailUrl =
      "https://cis.ncu.edu.tw/Course/main/support/courseDetail.html?crs=";

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
  final String? collegeName;
  final String? departmentName;
  final String? courseType;

  String get teacherText => teachers.isEmpty ? '未定' : teachers.join('、');

  String get classTimeText =>
      classTimes.isEmpty ? '時間未定' : classTimes.join('、');

  String get creditText => credit.toString();

  String get openingUnitText {
    final units = [
      if (collegeName != null && collegeName!.isNotEmpty) collegeName,
      if (departmentName != null && departmentName!.isNotEmpty) departmentName,
    ];
    if (units.isEmpty) return '開課單位未定';
    return units.join(' / ');
  }

  String get courseTypeText {
    final value = courseType?.trim();
    final normalized = value?.toUpperCase();

    return switch (normalized) {
      'REQUIRED' => '必修',
      'ELECTIVE' => '選修',
      'UNKNOWN' => '未知',
      _ when value == '必修' || value == '選修' => value!,
      _ when value != null && value.isNotEmpty => value,
      _ => '未分類',
    };
  }

  String get passwordCardText {
    final value = passwordCard?.trim();
    final normalized = value?.toUpperCase();

    return switch (normalized) {
      'NONE' => '無',
      'OPTIONAL' => '部分',
      'ALL' => '全部',
      _ when value != null && value.isNotEmpty => value,
      _ => '無',
    };
  }

  bool get showsPasswordCardHint => passwordCardText != '無';

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

  String get detailUrlWithParams => '$detailUrl$serialNo';
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
