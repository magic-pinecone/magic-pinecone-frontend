import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';

abstract class SettingsRepository {
  SettingsSnapshot loadSettings();
}
