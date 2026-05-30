class CourseSupplementalDetail {
  const CourseSupplementalDetail({
    required this.serialNo,
    required this.objectives,
    required this.content,
    required this.books,
    required this.teachingMethod,
    required this.gradingPolicy,
  });

  factory CourseSupplementalDetail.fromJson(Map<String, Object?> json) {
    return CourseSupplementalDetail(
      serialNo: json['serial_no'] as String,
      objectives: json['objectives'] as String? ?? '',
      content: json['content'] as String? ?? '',
      books: json['books'] as String? ?? '',
      teachingMethod: json['teaching_method'] as String? ?? '',
      gradingPolicy: json['grading_policy'] as String? ?? '',
    );
  }

  final String serialNo;
  final String objectives;
  final String content;
  final String books;
  final String teachingMethod;
  final String gradingPolicy;

  bool get hasContent {
    return objectives.isNotEmpty ||
        content.isNotEmpty ||
        books.isNotEmpty ||
        teachingMethod.isNotEmpty ||
        gradingPolicy.isNotEmpty;
  }
}
