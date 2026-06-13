import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/portal/data/data_sources/portal_authenticator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'refresh_portal_session_use_case.g.dart';

class RefreshPortalSessionUseCase {
  const RefreshPortalSessionUseCase(this._authenticator);

  final PortalAuthenticator _authenticator;

  Future<String?> execute() {
    return _authenticator.fetchPortalToken();
  }
}

@riverpod
RefreshPortalSessionUseCase refreshPortalSessionUseCase(Ref ref) {
  return RefreshPortalSessionUseCase(ref.watch(portalAuthenticatorProvider));
}
