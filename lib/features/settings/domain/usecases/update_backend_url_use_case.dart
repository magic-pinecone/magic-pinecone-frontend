import 'package:magic_pinecone/features/settings/domain/repository/settings_controls.dart';

class UpdateBackendUrlUseCase {
  const UpdateBackendUrlUseCase(this._configController);

  final BackendUrlConfig _configController;

  bool updateUrl(String url) {
    return _configController.setBaseUrl(url);
  }

  void reset() {
    _configController.reset();
  }
}
