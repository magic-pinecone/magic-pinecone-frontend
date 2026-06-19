import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_repository.dart';

class LoadSettingsUseCase {
  const LoadSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  SettingsSnapshot execute() {
    return _repository.loadSettings();
  }
}
