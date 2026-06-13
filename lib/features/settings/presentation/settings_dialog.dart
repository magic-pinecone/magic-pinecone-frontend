import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchCommunityUrl(BuildContext context, String url) async {
  final launched = await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  if (launched || !context.mounted) return;

  ScaffoldMessenger.maybeOf(
    context,
  )?.showSnackBar(SnackBar(content: Text('無法開啟連結：$url')));
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final themeMode = ref.watch(appThemeControllerProvider);
    final notifier = ref.read(settingsViewModelProvider.notifier);

    final content = _SettingsPageContent(
      state: state,
      themeMode: themeMode,
      notifier: notifier,
    );
    if (!showAppBar) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: content,
    );
  }
}

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(32.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560.0, maxHeight: 680.0),
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: const Text('設定'),
              actions: [
                IconButton(
                  tooltip: '關閉',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Expanded(child: SettingsPage(showAppBar: false)),
          ],
        ),
      ),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent({
    required this.state,
    required this.themeMode,
    required this.notifier,
  });

  final SettingsState state;
  final ThemeMode themeMode;
  final SettingsViewModel notifier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => Theme.of(context).brightness == Brightness.dark,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
      children: [
        Text(
          '顯示與偏好',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10.0),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('深色模式'),
                subtitle: Text(isDarkMode ? '開啟' : '關閉'),
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                value: isDarkMode,
                onChanged: notifier.setDarkMode,
              ),
              const Divider(height: 1.0),
              SwitchListTile(
                title: const Text('隱藏週末'),
                subtitle: Text(
                  state.omitWeekendsOnTimetable ? '只顯示週一到週五' : '顯示整週',
                ),
                secondary: const Icon(Icons.weekend_outlined),
                value: state.omitWeekendsOnTimetable,
                onChanged: notifier.setOmitWeekendsOnTimetable,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        _ProjectInfoSection(snapshot: state.snapshot),
        const SizedBox(height: 20.0),
        const _CommunitySection(),
        const SizedBox(height: 20.0),
        const _SpecialThanksSection(),
        const SizedBox(height: 24.0),
        const _LicenseFooter(),
      ],
    );
  }
}

class _SpecialThanksSection extends StatelessWidget {
  const _SpecialThanksSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '特別感謝',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10.0),
        const Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _CommunityTile(
                icon: Icon(Icons.volunteer_activism_outlined),
                title: 'OpenTPI（昕力資訊）',
                subtitle: '與昕力資訊 OpenTPI 開放原始碼專案計畫於2025-2026年度的合作，是促成神奇松果的起點。',
                url: 'https://tpi.dev/',
              ),
              Divider(height: 1.0),
              _CommunityTile(
                icon: FaIcon(FontAwesomeIcons.github),
                title: 'Course Finder Fetcher',
                subtitle: '課程資料擷取流程參考 NCU Course Finder 的 DataFetcher 專案。',
                url:
                    'https://github.com/zetaraku/NCU-Course-Finder-DataFetcher-v2',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommunitySection extends StatelessWidget {
  const _CommunitySection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '追蹤神奇松果 & GDGoC NCU',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10.0),
        const Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _CommunityTile(
                icon: FaIcon(FontAwesomeIcons.github),
                title: 'GitHub',
                subtitle: '追蹤神奇松果的進度或是參與開發，點個 Star 也不錯！:D',
                url: 'https://github.com/magic-pinecone/magic-pinecone-lite',
              ),
              Divider(height: 1.0),
              _CommunityTile(
                icon: FaIcon(FontAwesomeIcons.instagram),
                title: 'Instagram',
                subtitle: '追蹤GDGoC NCU的IG，獲得最新的活動資訊！',
                url: 'https://www.instagram.com/gdscncu/',
              ),
              Divider(height: 1.0),
              _CommunityTile(
                icon: FaIcon(FontAwesomeIcons.facebook),
                title: 'Facebook',
                subtitle: '追蹤GDGoC NCU的FB粉專，獲得最新的活動資訊！',
                url: 'https://www.facebook.com/GDSCNCU',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: IconTheme(
        data: IconThemeData(color: colorScheme.primary, size: 22.0),
        child: icon,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => unawaited(_launchCommunityUrl(context, url)),
    );
  }
}

class _LicenseFooter extends StatelessWidget {
  const _LicenseFooter();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Text(
      'Licensed under the MIT License\n'
      'Copyright (c) 2026 Yu-Hsiang Lin, Yi-Chung Chang and Jing-Lun Huang\n@GDGoC NCU\n'
      'This project is neither affiliated nor endorsed by National Central University.',
      textAlign: TextAlign.center,
      style: textStyle,
    );
  }
}

class _ProjectInfoSection extends StatelessWidget {
  const _ProjectInfoSection({required this.snapshot});

  final SettingsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '專案資訊',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10.0),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        snapshot.appName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'v${snapshot.appVersion}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  snapshot.summary,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16.0),
                for (var i = 0; i < snapshot.statusItems.length; i++) ...[
                  _StatusRow(item: snapshot.statusItems[i]),
                  if (i < snapshot.statusItems.length - 1)
                    const SizedBox(height: 8.0),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.item});

  final SettingsStatusItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            item.label,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
