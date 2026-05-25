import 'package:flutter/foundation.dart';

const defaultBackendBaseUrl = 'http://localhost:18080';

class AppBackendConfigController extends ChangeNotifier {
  AppBackendConfigController({String baseUrl = defaultBackendBaseUrl})
    : _baseUrl = _normalize(baseUrl);

  String _baseUrl;

  String get baseUrl => _baseUrl;

  bool setBaseUrl(String value) {
    final normalized = _normalize(value);
    if (!_isSupportedBaseUrl(normalized)) return false;
    if (_baseUrl == normalized) return true;
    _baseUrl = normalized;
    notifyListeners();
    return true;
  }

  void reset() {
    setBaseUrl(defaultBackendBaseUrl);
  }

  static String _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  static bool _isSupportedBaseUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
