import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/core/widgets/owned_change_notifier_builder.dart';
import 'package:prototype/features/news/models/news_digest_item.dart';
import 'package:prototype/features/news/models/scholarship_item.dart';
import 'package:prototype/features/news/presentation/view_models/news_view_model.dart';
import 'package:prototype/features/news/presentation/widgets/announcement_card.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key, this.viewModel});

  static const _tabs = ['全部', '獎學金', '工讀職缺', '校務公告', '活動'];

  final NewsViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return OwnedChangeNotifierBuilder<NewsViewModel>(
      notifier: viewModel,
      create: (context) => AppScope.of(context).createNewsViewModel(),
      onReady: (viewModel) => unawaited(viewModel.load()),
      builder: (context, viewModel) => DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              '訊息',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          body: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              return Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: TabBarView(
                      children: _tabs
                          .map(
                            (tab) => _NewsTabContent(
                              category: tab,
                              items: viewModel.items,
                              isLoading: viewModel.isLoading,
                              error: viewModel.error,
                              onRetry: viewModel.load,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: 1.0,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _TodayDigestPanel(items: viewModel.digestItems),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TodayDigestPanel extends StatelessWidget {
  const _TodayDigestPanel({required this.items});

  final List<NewsDigestItem> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
      children: [
        Row(
          children: [
            Icon(Icons.wb_sunny_outlined, color: colorScheme.primary),
            const SizedBox(width: 8.0),
            const Text(
              '今日整理',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Text(
          '把本週需要處理的校園重點集中在同一個地方，方便展示與後續擴充。',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16.0),
        for (final item in items) ...[
          _NewsDigestCard(item: item),
          const SizedBox(height: 12.0),
        ],
      ],
    );
  }
}

class _NewsDigestCard extends StatelessWidget {
  const _NewsDigestCard({required this.item});

  final NewsDigestItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(item.icon, color: item.color),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    item.description,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsTabContent extends StatelessWidget {
  const _NewsTabContent({
    required this.category,
    required this.items,
    required this.isLoading,
    required this.onRetry,
    this.error,
  });

  final String category;
  final List<ScholarshipItem> items;
  final bool isLoading;
  final Future<void> Function() onRetry;
  final Object? error;

  List<ScholarshipItem> get _filteredItems {
    if (category == '全部') return items;
    return items.where((item) => item.tabLabel == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('載入失敗，請稍後再試'),
            const SizedBox(height: 12.0),
            FilledButton(onPressed: onRetry, child: const Text('重新載入')),
          ],
        ),
      );
    }

    final displayItems = _filteredItems;
    if (displayItems.isEmpty) {
      return const Center(child: Text('目前沒有資料'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      itemCount: displayItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8.0),
      itemBuilder: (_, index) {
        final item = displayItems[index];
        return AnnouncementCard(
          label: item.tabLabel,
          title: item.title,
          date: item.endDate,
        );
      },
    );
  }
}
