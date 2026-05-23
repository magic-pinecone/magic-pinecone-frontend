enum ScholarshipCategory {
  scholarship, // 獎學金
  graduateScholarship, // 研究生獎學金
  partTime, // 工讀資訊
}

class ScholarshipItem {
  const ScholarshipItem({
    required this.category,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.eligibility = '',
  });

  final ScholarshipCategory category;
  final String title;
  final String startDate;
  final String endDate;
  final String eligibility;

  /// Maps to the tab label used in the news page.
  String get tabLabel {
    return switch (category) {
      ScholarshipCategory.scholarship ||
      ScholarshipCategory.graduateScholarship => '獎學金',
      ScholarshipCategory.partTime => '工讀職缺',
    };
  }
}
