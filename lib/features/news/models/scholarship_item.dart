class ScholarshipItem {
  const ScholarshipItem({
    required this.id,
    required this.category,
    required this.title,
    this.contentSummary,
    this.downloadLink,
  });

  final int id;
  final String category;
  final String title;
  final String? contentSummary;
  final String? downloadLink;

  /// Maps to the tab label used in the news page.
  String get tabLabel {
    return category == '招募資訊' ? '工讀職缺' : category;
  }
}
