import 'package:magic_pinecone/features/news/data/news_digest_catalog.dart';
import 'package:magic_pinecone/features/news/models/news_digest_item.dart';

abstract class NewsDigestRepository {
  List<NewsDigestItem> loadDigestItems();
}

class StaticNewsDigestRepository implements NewsDigestRepository {
  const StaticNewsDigestRepository();

  @override
  List<NewsDigestItem> loadDigestItems() {
    return todayDigestItems;
  }
}
