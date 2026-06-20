import 'package:magic_pinecone/features/news/domain/models/news_digest_item.dart';
import 'package:magic_pinecone/features/news/domain/models/scholarship_item.dart';
import 'package:magic_pinecone/features/news/news_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'news_view_model.g.dart';

@riverpod
class NewsViewModel extends _$NewsViewModel {
  @override
  FutureOr<NewsViewSnapshot> build() async {
    final digestItems = ref.watch(loadNewsDigestUseCaseProvider).execute();
    final scholarshipItems = await ref
        .watch(fetchScholarshipsUseCaseProvider)
        .execute();
    return NewsViewSnapshot(
      scholarshipItems: scholarshipItems,
      digestItems: digestItems,
    );
  }
}

class NewsViewSnapshot {
  NewsViewSnapshot({required this.scholarshipItems, required this.digestItems});

  final List<ScholarshipItem> scholarshipItems;
  final List<NewsDigestItem> digestItems;
}
