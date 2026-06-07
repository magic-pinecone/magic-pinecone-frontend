import 'package:flutter/material.dart';
import 'package:magic_pinecone/features/portal/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/presentation/widgets/portal_shortcut_button.dart';

class PortalShortcutsPage extends StatefulWidget {
  const PortalShortcutsPage({
    super.key,
    this.title = '校務系統',
    required this.sections,
    required this.onShortcutTap,
    this.appBarActions,
    this.initialSearchQuery = '',
  });

  final String title;
  final List<PortalShortcutSection> sections;
  final ValueChanged<PortalShortcutItem> onShortcutTap;
  final List<Widget>? appBarActions;
  final String initialSearchQuery;

  @override
  State<PortalShortcutsPage> createState() => _PortalShortcutsPageState();
}

class _PortalShortcutsPageState extends State<PortalShortcutsPage> {
  late final TextEditingController _searchController;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery;
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSections = widget.sections
        .map((section) {
          final filteredItems = section.items
              .where(
                (item) => item.label.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
          if (filteredItems.isEmpty) return null;
          return PortalShortcutSection(
            title: section.title,
            items: filteredItems,
          );
        })
        .whereType<PortalShortcutSection>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: widget.appBarActions,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          SearchBar(
            controller: _searchController,
            hintText: '搜尋功能...',
            leading: const Icon(Icons.search),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          if (filteredSections.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Center(child: Text('找不到相關功能')),
            )
          else
            for (final section in filteredSections) ...[
              _PortalSectionTitle(title: section.title),
              const SizedBox(height: 8.0),
              _ShortcutGrid(items: section.items, onTap: widget.onShortcutTap),
              const SizedBox(height: 20.0),
            ],
        ],
      ),
    );
  }
}

class _PortalSectionTitle extends StatelessWidget {
  const _PortalSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({required this.items, required this.onTap});

  final List<PortalShortcutItem> items;
  final ValueChanged<PortalShortcutItem> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        const columns = 4;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 12.0,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: Center(
                  child: PortalShortcutButton(
                    icon: item.icon,
                    label: item.label,
                    color: const Color(0xFF4A90D9),
                    onPressed: () => onTap(item),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
