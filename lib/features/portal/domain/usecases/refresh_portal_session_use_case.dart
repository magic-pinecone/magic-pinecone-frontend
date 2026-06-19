import 'package:magic_pinecone/features/portal/data/data_sources/portal_authenticator.dart';

class RefreshPortalSessionUseCase {
  const RefreshPortalSessionUseCase(this._authenticator);

  final PortalAuthenticator _authenticator;

  Future<String?> execute() {
    return _authenticator.fetchPortalToken();
  }
}
