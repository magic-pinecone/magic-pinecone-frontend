class ScholarshipItem {
  const ScholarshipItem({
    required this.id,
    required this.category,
    required this.title,
    required this.contentSummary,
    this.downloadLink,
  });

  final int id;
  final String category;
  final String title;
  final String contentSummary;
  final String? downloadLink;

  /// Maps to the tab label used in the news page.
  String get tabLabel {
    return category == '招募資訊' ? '工讀職缺' : category;
  }

  Map<String, String> parseSummary() {
    if (contentSummary.trim().isEmpty) {
      return {};
    }
    final Map<String, String> summaryMap = {};
    final lines = contentSummary.split('\n');
    for (final line in lines) {
      final separatorIndex = line.indexOf(RegExp('[:：]'));
      if (separatorIndex > 0) {
        final key = line.substring(0, separatorIndex).trim();
        final value = line.substring(separatorIndex + 1).trim();
        summaryMap[key] = value;
      }
    }
    return summaryMap;
  }
}
