import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/news/data/news_digest_repository.dart';
import 'package:magic_pinecone/features/news/data/scholarship_repository.dart';
import 'package:magic_pinecone/features/news/models/news_digest_item.dart';
import 'package:magic_pinecone/features/news/models/scholarship_item.dart';
import 'package:magic_pinecone/features/news/presentation/news_page.dart';
import 'package:magic_pinecone/features/news/presentation/view_models/news_view_model.dart';

void main() {
  testWidgets('NewsPage renders fetched news', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewsPage(
          viewModel: NewsViewModel(
            repository: FakeScholarshipRepository(
              result: const [
                ScholarshipItem(
                  id: 1,
                  category: '獎學金',
                  title: '校內獎學金申請公告',
                  contentSummary:
                      '開始日期: 2026-05-07\n'
                      '結束日期: 2026-06-04\n'
                      '申請資格: 不拘',
                ),
              ],
            ),
            digestRepository: const FakeNewsDigestRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('校內獎學金申請公告'), findsOneWidget);
    expect(find.text('2026-05-07 - 2026-06-04'), findsOneWidget);
    expect(find.text('申請資格: 不拘'), findsOneWidget);
    expect(find.text('查看'), findsOneWidget);
  });
}

class FakeScholarshipRepository implements ScholarshipRepository {
  FakeScholarshipRepository({this.result = const [], this.error});

  final List<ScholarshipItem> result;
  final Object? error;

  @override
  Future<List<ScholarshipItem>> fetchScholarships() async {
    if (error != null) throw error!;
    return result;
  }
}

class FakeNewsDigestRepository implements NewsDigestRepository {
  const FakeNewsDigestRepository();

  @override
  List<NewsDigestItem> loadDigestItems() {
    return const [
      NewsDigestItem(
        title: '本週課務重點',
        description: '優先確認選課、加退選與期中預警時程。',
        icon: Icons.event_available,
        color: Color(0xFF4A90D9),
      ),
      NewsDigestItem(
        title: '獎助資訊提醒',
        description: '獎學金與工讀職缺公告建議每天檢查一次。',
        icon: Icons.campaign_outlined,
        color: Color(0xFFFF9800),
      ),
    ];
  }
}
