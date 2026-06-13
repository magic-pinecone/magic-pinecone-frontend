import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/news/domain/models/news_digest_item.dart';
import 'package:magic_pinecone/features/news/domain/repository/news_digest_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_news_digest_use_case.g.dart';

class LoadNewsDigestUseCase {
  const LoadNewsDigestUseCase(this._repository);

  final NewsDigestRepository _repository;

  List<NewsDigestItem> execute() {
    return _repository.loadDigestItems();
  }
}

@riverpod
LoadNewsDigestUseCase loadNewsDigestUseCase(Ref ref) {
  return LoadNewsDigestUseCase(ref.watch(newsDigestRepositoryProvider));
}
