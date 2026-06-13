import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/presentation/view_models/settings_view_model.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final themeMode = ref.watch(appThemeControllerProvider);
    final backendBaseUrl = ref.watch(appBackendConfigControllerProvider);
    final notifier = ref.read(settingsViewModelProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => Theme.of(context).brightness == Brightness.dark,
    };

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text(
                '設定',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: ListView(
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
            child: SwitchListTile(
              title: const Text('深色模式'),
              subtitle: Text(isDarkMode ? '開啟' : '關閉'),
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: isDarkMode,
              onChanged: notifier.setDarkMode,
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            '後端服務',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10.0),
          _BackendEndpointCard(
            state: state,
            notifier: notifier,
            backendBaseUrl: backendBaseUrl,
          ),
          const SizedBox(height: 20.0),
          _ProjectInfoSection(snapshot: state.snapshot),
        ],
      ),
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

class _BackendEndpointCard extends StatefulWidget {
  const _BackendEndpointCard({
    required this.state,
    required this.notifier,
    required this.backendBaseUrl,
  });

  final SettingsState state;
  final SettingsViewModel notifier;
  final String backendBaseUrl;

  @override
  State<_BackendEndpointCard> createState() => _BackendEndpointCardState();
}

class _BackendEndpointCardState extends State<_BackendEndpointCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.backendBaseUrl);
  }

  @override
  void didUpdateWidget(covariant _BackendEndpointCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.backendBaseUrl != _controller.text) {
      _controller.text = widget.backendBaseUrl;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Backend URL',
                hintText: 'http://localhost:18080',
                errorText: widget.state.backendBaseUrlError,
                prefixIcon: const Icon(Icons.dns_outlined),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              onSubmitted: widget.notifier.updateBackendBaseUrl,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.notifier.resetBackendBaseUrl,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('重設'),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        widget.notifier.updateBackendBaseUrl(_controller.text),
                    icon: const Icon(Icons.check),
                    label: const Text('套用'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
