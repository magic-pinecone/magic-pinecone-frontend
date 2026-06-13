import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/news/domain/models/scholarship_item.dart';

void main() {
  test(
    'applicationSearchUrl builds CIS scholarship query from title and type',
    () {
      const item = ScholarshipItem(
        id: 1,
        category: '獎學金',
        title: '校內獎學金申請公告',
        contentSummary: '',
      );

      expect(item.applicationSearchUrl.scheme, 'https');
      expect(item.applicationSearchUrl.host, 'cis.ncu.edu.tw');
      expect(item.applicationSearchUrl.path, '/Scholarship');
      expect(item.applicationSearchUrl.queryParameters, {
        'searchJob': '校內獎學金申請公告',
        'ChooseType': 'scholar',
      });
    },
  );

  test('applicationSearchUrl maps part-time job category to CIS type', () {
    const item = ScholarshipItem(
      id: 2,
      category: '招募資訊',
      title: '諮商輔導中心工讀',
      contentSummary: '',
    );

    expect(item.applicationSearchUrl.queryParameters, {
      'searchJob': '諮商輔導中心工讀',
      'ChooseType': 'parttime',
    });
  });

  // TODO: this is not needed after backend update return format
  test(
    'parseSummary handles backend content summary with ASCII separators',
    () {
      const item = ScholarshipItem(
        id: 1,
        category: '招募資訊',
        title: '諮商輔導中心工讀',
        contentSummary:
            '開始日期 : 2026-05-07\n'
            '結束日期 : 2026-06-04\n'
            '申請資格 : 不拘\n'
            '工讀單位 : 諮商輔導中心\n'
            '工讀地點 : 諮商輔導中心\n'
            '工讀類型 :',
      );

      expect(item.parseSummary(), {
        '開始日期': '2026-05-07',
        '結束日期': '2026-06-04',
        '申請資格': '不拘',
        '工讀單位': '諮商輔導中心',
        '工讀地點': '諮商輔導中心',
        '工讀類型': '',
      });
      expect(item.dateText, '2026-05-07 - 2026-06-04');
      expect(item.summaryPreview, '申請資格: 不拘\n工讀單位: 諮商輔導中心\n工讀地點: 諮商輔導中心');
    },
  );
}
