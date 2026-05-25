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

  String get dateText {
    final fields = parseSummary();
    final start = fields['開始日期'];
    final end = fields['結束日期'];

    if (_hasValue(start) && _hasValue(end)) return '$start - $end';
    if (_hasValue(start)) return start!;
    if (_hasValue(end)) return end!;
    return '日期未提供';
  }

  String get summaryPreview {
    final fields = Map<String, String>.of(parseSummary())
      ..remove('開始日期')
      ..remove('結束日期');
    final preview = fields.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    if (preview.isNotEmpty) return preview;

    final rawSummary = contentSummary.trim();
    if (rawSummary.isEmpty) return '摘要未提供';
    return rawSummary.split('\n').first;
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

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
