import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/news/models/scholarship_item.dart';

void main() {
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
    },
  );
}
