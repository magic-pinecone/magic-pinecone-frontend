import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/features/news/data/news_digest_repository.dart';
import 'package:prototype/features/news/data/scholarship_repository.dart';
import 'package:prototype/features/news/models/news_digest_item.dart';
import 'package:prototype/features/news/models/scholarship_item.dart';
import 'package:prototype/features/news/presentation/view_models/news_view_model.dart';

void main() {
  group('NewsViewModel', () {
    test('loads items from repository and clears loading state', () async {
      final repository = FakeScholarshipRepository(
        result: const [
          ScholarshipItem(
            category: ScholarshipCategory.scholarship,
            title: 'Test scholarship',
            startDate: '2026-01-01',
            endDate: '2026-02-01',
          ),
        ],
      );
      final viewModel = NewsViewModel(
        repository: repository,
        digestRepository: const FakeNewsDigestRepository(),
      );

      await viewModel.load();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.items, hasLength(1));
      expect(viewModel.items.first.title, 'Test scholarship');
      expect(viewModel.digestItems, hasLength(1));
    });

    test('stores error when repository throws', () async {
      final repository = FakeScholarshipRepository(
        error: StateError('fetch failed'),
      );
      final viewModel = NewsViewModel(
        repository: repository,
        digestRepository: const FakeNewsDigestRepository(),
      );

      await viewModel.load();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.items, isEmpty);
      expect(viewModel.error, isA<StateError>());
    });
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
        title: 'Digest',
        description: 'Digest description',
        icon: Icons.info_outline,
        color: Color(0xFF4A90D9),
      ),
    ];
  }
}
