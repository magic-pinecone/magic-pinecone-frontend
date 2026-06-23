import 'package:magic_pinecone/features/news/domain/models/news_digest_item.dart';
import 'package:magic_pinecone/features/news/domain/repository/news_digest_repository.dart';

class LoadNewsDigestUseCase {
  const LoadNewsDigestUseCase(this._repository);

  final NewsDigestRepository _repository;

  List<NewsDigestItem> execute() {
    return _repository.loadDigestItems();
  }
}
