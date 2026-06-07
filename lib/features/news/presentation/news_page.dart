import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/core/navigation/app_routes.dart';
import 'package:magic_pinecone/features/news/models/scholarship_item.dart';
import 'package:magic_pinecone/features/news/presentation/view_models/news_view_model.dart';
import 'package:magic_pinecone/features/news/presentation/widgets/announcement_card.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key, this.viewModel});

  static const _tabs = ['全部', '獎學金', '工讀職缺', '校務公告', '活動'];

  final NewsViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final hasScope =
        context.findAncestorWidgetOfExactType<ProviderScope>() != null ||
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() !=
            null;

    final child = _NewsPageInner(viewModel: viewModel);

    if (hasScope) {
      return child;
    } else {
      return ProviderScope(child: child);
    }
  }
}

class _NewsPageInner extends ConsumerStatefulWidget {
  const _NewsPageInner({this.viewModel});

  final NewsViewModel? viewModel;

  @override
  ConsumerState<_NewsPageInner> createState() => _NewsPageInnerState();
}

class _NewsPageInnerState extends ConsumerState<_NewsPageInner> {
  late final NewsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? ref.read(newsViewModelProvider);
    scheduleMicrotask(() {
      if (mounted) {
        unawaited(_viewModel.load());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel == null) {
      ref.watch(newsViewModelProvider);
    }
    return DefaultTabController(
      length: NewsPage._tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '訊息',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: NewsPage._tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: TabBarView(
          children: NewsPage._tabs
              .map(
                (tab) => ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    // TODO: Add the planned digest section
                    return _NewsTabContent(
                      category: tab,
                      items: _viewModel.items,
                      isLoading: _viewModel.isLoading,
                      error: _viewModel.error,
                      onRetry: _viewModel.load,
                    );
                  },
                ),
              )
              .toList(),
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
          date: item.dateText,
          summary: item.summaryPreview,
          onTap: () => _openScholarshipApplication(context, item),
          actionLabel: '查看',
          onActionPressed: () => _openScholarshipInBrowser(item),
        );
      },
    );
  }

  void _openScholarshipApplication(BuildContext context, ScholarshipItem item) {
    unawaited(
      Navigator.of(context).push(
        AppRoutes.portalWebView(
          title: item.title,
          targetUrl: item.applicationSearchUrl,
        ),
      ),
    );
  }

  void _openScholarshipInBrowser(ScholarshipItem item) {
    unawaited(
      InAppBrowser.openWithSystemBrowser(
        url: WebUri.uri(item.applicationSearchUrl),
      ),
    );
  }
}
