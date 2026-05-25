import 'package:flutter/material.dart';
import 'package:prototype/core/app/app_scope.dart';
import 'package:prototype/core/widgets/owned_change_notifier_builder.dart';
import 'package:prototype/features/settings/models/settings_models.dart';
import 'package:prototype/features/settings/presentation/view_models/settings_view_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.viewModel});

  final SettingsViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return OwnedChangeNotifierBuilder<SettingsViewModel>(
      notifier: viewModel,
      create: (context) => AppScope.of(context).createSettingsViewModel(),
      builder: (context, viewModel) =>
          _SettingsPageContent(viewModel: viewModel),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent({required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
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
                child: SwitchListTile(
                  title: const Text('深色模式'),
                  subtitle: Text(viewModel.isDarkMode ? '開啟' : '關閉'),
                  secondary: Icon(
                    viewModel.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  value: viewModel.isDarkMode,
                  onChanged: (_) => viewModel.toggleTheme(),
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
              _BackendEndpointCard(viewModel: viewModel),
              const SizedBox(height: 20.0),
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
                              viewModel.appName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'v${viewModel.appVersion}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        viewModel.summary,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16.0),
                      for (
                        var i = 0;
                        i < viewModel.statusItems.length;
                        i++
                      ) ...[
                        _StatusRow(item: viewModel.statusItems[i]),
                        if (i < viewModel.statusItems.length - 1)
                          const SizedBox(height: 8.0),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackendEndpointCard extends StatefulWidget {
  const _BackendEndpointCard({required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<_BackendEndpointCard> createState() => _BackendEndpointCardState();
}

class _BackendEndpointCardState extends State<_BackendEndpointCard> {
  late final TextEditingController _controller;

  SettingsViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: viewModel.backendBaseUrl);
  }

  @override
  void didUpdateWidget(covariant _BackendEndpointCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (viewModel.backendBaseUrl != _controller.text) {
      _controller.text = viewModel.backendBaseUrl;
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
                errorText: viewModel.backendBaseUrlError,
                prefixIcon: const Icon(Icons.dns_outlined),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              onSubmitted: viewModel.updateBackendBaseUrl,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: viewModel.resetBackendBaseUrl,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('重設'),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        viewModel.updateBackendBaseUrl(_controller.text),
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
