import 'package:magic_pinecone/features/portal/domain/repository/portal_session_client.dart';

class RefreshPortalSessionUseCase {
  const RefreshPortalSessionUseCase(this._sessionClient);

  final PortalSessionClient _sessionClient;

  Future<String?> execute() {
    return _sessionClient.refreshToken();
  }
}
