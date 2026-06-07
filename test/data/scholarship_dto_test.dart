import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/news/data/dtos/scholarship_dto.dart';

void main() {
  test('ScholarshipResultDto parses backend scholarship response', () {
    final result = ScholarshipResultDto.fromJson(const {
      'total_count': 1,
      'last_updated': '2026-05-24T08:30:00Z',
      'scholarships': [
        {
          'id': 7,
          'category': '招募資訊',
          'title': '校內工讀招募',
          'content_summary': '工讀單位與申請資訊',
          'download_link': 'https://example.com/file.pdf',
        },
      ],
    });

    expect(result.totalCount, 1);
    expect(result.lastUpdated, DateTime.utc(2026, 5, 24, 8, 30));
    expect(result.scholarships.single.id, 7);
    expect(result.scholarships.single.category, '招募資訊');
    expect(result.scholarships.single.title, '校內工讀招募');
    expect(result.scholarships.single.contentSummary, '工讀單位與申請資訊');
    expect(
      result.scholarships.single.downloadLink,
      'https://example.com/file.pdf',
    );
  });

  test(
    'ScholarshipResultDto parses nullable map content summary from OpenAPI',
    () {
      final result = ScholarshipResultDto.fromJson(const {
        'total_count': 2,
        'scholarships': [
          {
            'id': 8,
            'category': '招募資訊',
            'title': '校內工讀招募',
            'content_summary': {
              '開始日期': '2026-05-07',
              '結束日期': '2026-06-04',
              '申請資格': '不拘',
            },
          },
          {
            'id': 9,
            'category': '獎學金',
            'title': '獎學金公告',
            'content_summary': null,
          },
        ],
      });

      expect(
        result.scholarships.first.contentSummary,
        '開始日期: 2026-05-07\n結束日期: 2026-06-04\n申請資格: 不拘',
      );
      expect(result.scholarships.last.contentSummary, isEmpty);
    },
  );
}
