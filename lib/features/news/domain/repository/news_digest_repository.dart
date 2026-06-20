import 'package:magic_pinecone/features/news/domain/models/news_digest_item.dart';

abstract class NewsDigestRepository {
  List<NewsDigestItem> loadDigestItems();
}
