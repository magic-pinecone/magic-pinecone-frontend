import 'package:magic_pinecone/core/app/app_backend_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_backend_url_use_case.g.dart';

class UpdateBackendUrlUseCase {
  const UpdateBackendUrlUseCase(this._configController);

  final AppBackendConfigController _configController;

  bool updateUrl(String url) {
    return _configController.setBaseUrl(url);
  }

  void reset() {
    _configController.reset();
  }
}

@riverpod
UpdateBackendUrlUseCase updateBackendUrlUseCase(Ref ref) {
  return UpdateBackendUrlUseCase(
    ref.watch(appBackendConfigControllerProvider.notifier),
  );
}
