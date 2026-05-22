class SettingsStatusItem {
  const SettingsStatusItem({required this.label});

  final String label;
}

class SettingsSnapshot {
  const SettingsSnapshot({
    required this.appName,
    required this.appVersion,
    required this.summary,
    required this.statusItems,
  });

  final String appName;
  final String appVersion;
  final String summary;
  final List<SettingsStatusItem> statusItems;
}
