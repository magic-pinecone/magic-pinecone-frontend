import 'package:prototype/features/news/data/news_digest_catalog.dart';
import 'package:prototype/features/news/models/news_digest_item.dart';

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
