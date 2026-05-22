import 'package:flutter/foundation.dart';
import 'package:prototype/features/news/data/news_digest_repository.dart';
import 'package:prototype/features/news/models/news_digest_item.dart';
import 'package:prototype/features/news/data/scholarship_repository.dart';
import 'package:prototype/features/news/models/scholarship_item.dart';

class NewsViewModel extends ChangeNotifier {
  NewsViewModel({
    required ScholarshipRepository repository,
    required NewsDigestRepository digestRepository,
  }) : _repository = repository,
       _digestItems = List.unmodifiable(digestRepository.loadDigestItems());

  final ScholarshipRepository _repository;
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
      _items = await _repository.fetchScholarships();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
