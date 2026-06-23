class CourseSupplementalDetail {
  const CourseSupplementalDetail({
    required this.serialNo,
    required this.objectives,
    required this.content,
    required this.books,
    required this.teachingMethod,
    required this.gradingPolicy,
    this.distributionConditions = const [],
  });

  factory CourseSupplementalDetail.fromJson(Map<String, Object?> json) {
    return CourseSupplementalDetail(
      serialNo: json['serial_no'] as String,
      objectives: json['objectives'] as String? ?? '',
      content: json['content'] as String? ?? '',
      books: json['books'] as String? ?? '',
      teachingMethod: json['teaching_method'] as String? ?? '',
      gradingPolicy: json['grading_policy'] as String? ?? '',
      distributionConditions: _decodeDistributionConditions(
        json['distribution_conditions'],
      ),
    );
  }

  final String serialNo;
  final String objectives;
  final String content;
  final String books;
  final String teachingMethod;
  final String gradingPolicy;
  final List<CourseDistributionCondition> distributionConditions;

  String get distributionConditionText {
    final seen = <String>{};
    final lines = <String>[];
    for (final condition in distributionConditions) {
      final text = condition.displayText;
      if (text.isEmpty || !seen.add(text)) continue;
      lines.add(text);
    }
    return lines.join('\n');
  }

  bool get hasContent {
    return objectives.isNotEmpty ||
        content.isNotEmpty ||
        books.isNotEmpty ||
        teachingMethod.isNotEmpty ||
        gradingPolicy.isNotEmpty ||
        distributionConditions.isNotEmpty;
  }

  static List<CourseDistributionCondition> _decodeDistributionConditions(
    Object? value,
  ) {
    if (value is! List<Object?>) return const [];

    return value
        .whereType<Map<Object?, Object?>>()
        .map(CourseDistributionCondition.fromJson)
        .where((condition) => condition.rule.isNotEmpty)
        .toList(growable: false);
  }
}

class CourseDistributionCondition {
  const CourseDistributionCondition({
    required this.priority,
    required this.rule,
  });

  factory CourseDistributionCondition.fromJson(Map<Object?, Object?> json) {
    return CourseDistributionCondition(
      priority: (json['priority'] as num?)?.toInt(),
      rule: (json['rule'] as String? ?? '').trim(),
    );
  }

  final int? priority;
  final String rule;

  String get displayText {
    if (rule.isEmpty) return '';
    final priorityLabel = priority?.toString();
    return priorityLabel == null ? rule : '$priorityLabel：$rule';
  }
}
