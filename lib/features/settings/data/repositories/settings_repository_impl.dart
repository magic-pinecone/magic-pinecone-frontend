import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_repository.dart';

class StaticSettingsRepository implements SettingsRepository {
  const StaticSettingsRepository();

  @override
  SettingsSnapshot loadSettings() {
    return const SettingsSnapshot(
      appName: 'Magic Pinecone',
      appVersion: '0.1.0+1',
      summary: '目前版本聚焦在行動端展示，已整理首頁、訊息、Portal 與課表等核心流程，作為學期末展示的穩定基礎。',
      statusItems: [
        SettingsStatusItem(label: '首頁與快速功能已串成實際流程'),
        SettingsStatusItem(label: '訊息與課表頁面已有結構化內容'),
        SettingsStatusItem(label: 'Portal 搜尋與登入狀態已可驗證'),
      ],
    );
  }
}
