import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:prototype/features/news/models/scholarship_item.dart';

class ScholarshipService {
  static const _url = 'https://cis.ncu.edu.tw/Scholarship/';

  Future<List<ScholarshipItem>> fetchScholarships() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load scholarship data');
    }
    return _parse(response.body);
  }

  static List<ScholarshipItem> _parse(String html) {
    final document = html_parser.parse(html);
    final boxes = document.querySelectorAll('.news_box');
    final items = <ScholarshipItem>[];

    for (final box in boxes) {
      final ScholarshipCategory? category;
      final titleEl =
          box.querySelector('.scholar') ??
          box.querySelector('.graduate') ??
          box.querySelector('.parttime');
      if (titleEl == null) continue;

      if (box.querySelector('.scholar') != null) {
        category = ScholarshipCategory.scholarship;
      } else if (box.querySelector('.graduate') != null) {
        category = ScholarshipCategory.graduateScholarship;
      } else {
        category = ScholarshipCategory.partTime;
      }

      // Extract title text (remove the [type] span prefix)
      final typeSpan = titleEl.querySelector('.type');
      String title = titleEl.text.trim();
      if (typeSpan != null) {
        title = title.replaceFirst(typeSpan.text, '').trim();
      }

      // Parse the news_content for dates
      final contentEl = box.querySelector('.news_content');
      final contentText = contentEl?.text ?? '';
      final startDate = _extractField(contentText, '開始日期');
      final endDate = _extractField(contentText, '結束日期');
      final eligibility = _extractField(contentText, '申請資格');

      items.add(
        ScholarshipItem(
          category: category,
          title: title,
          startDate: startDate,
          endDate: endDate,
          eligibility: eligibility,
        ),
      );
    }

    return items;
  }

  static String _extractField(String text, String fieldName) {
    final pattern = RegExp(
      '$fieldName\\s*:\\s*([^\\n]+?)(?=\\s*(?:結束日期|申請資格|申請辦法|所屬系所|獎學金類型|工讀單位|工讀地點|工讀類型|\$))',
    );
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
}
