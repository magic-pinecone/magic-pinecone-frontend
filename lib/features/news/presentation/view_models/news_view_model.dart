import 'package:flutter/foundation.dart';
import 'package:magic_pinecone/features/news/domain/models/news_digest_item.dart';
import 'package:magic_pinecone/features/news/domain/models/scholarship_item.dart';
import 'package:magic_pinecone/features/news/domain/repository/news_digest_repository.dart';
import 'package:magic_pinecone/features/news/domain/repository/scholarship_repository.dart';

// TODO: Migrate this controller from ChangeNotifier to a modern Riverpod Notifier/AsyncNotifier
class NewsViewModel extends ChangeNotifier {
  NewsViewModel({
    required this.repository,
    required NewsDigestRepository digestRepository,
  }) : _digestItems = List.unmodifiable(digestRepository.loadDigestItems());

  final ScholarshipRepository repository;
  final List<NewsDigestItem> _digestItems;

  bool _isLoading = false;
  Object? _error;
  List<ScholarshipItem> _items = const [];

  bool get isLoading => _isLoading;
  Object? get error => _error;
  List<ScholarshipItem> get items => _items;
  List<NewsDigestItem> get digestItems => _digestItems;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await repository.fetchScholarships();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
