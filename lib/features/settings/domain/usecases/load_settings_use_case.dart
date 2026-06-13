import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/settings/domain/models/settings_models.dart';
import 'package:magic_pinecone/features/settings/domain/repository/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_settings_use_case.g.dart';

class LoadSettingsUseCase {
  const LoadSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  SettingsSnapshot execute() {
    return _repository.loadSettings();
  }
}

@riverpod
LoadSettingsUseCase loadSettingsUseCase(Ref ref) {
  return LoadSettingsUseCase(ref.watch(settingsRepositoryProvider));
}
