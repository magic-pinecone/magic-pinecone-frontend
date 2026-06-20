import 'package:magic_pinecone/features/news/data/data_sources/news_digest_catalog.dart';
import 'package:magic_pinecone/features/news/domain/models/news_digest_item.dart';
import 'package:magic_pinecone/features/news/domain/repository/news_digest_repository.dart';

class StaticNewsDigestRepository implements NewsDigestRepository {
  const StaticNewsDigestRepository();

  @override
  List<NewsDigestItem> loadDigestItems() {
    return todayDigestItems;
  }
}
