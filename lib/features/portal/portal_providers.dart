import 'package:magic_pinecone/features/portal/data/data_sources/headless_webview_portal_session_client.dart';
import 'package:magic_pinecone/features/portal/data/repositories/portal_shortcut_repository_impl.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_session_client.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_shortcut_repository.dart';
import 'package:magic_pinecone/features/portal/domain/usecases/load_portal_shortcuts_use_case.dart';
import 'package:magic_pinecone/features/portal/domain/usecases/refresh_portal_session_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'portal_providers.g.dart';

@riverpod
PortalShortcutRepository portalShortcutRepository(Ref ref) {
  return const StaticPortalShortcutRepository();
}

@riverpod
PortalSessionClient portalSessionClient(Ref ref) {
  return HeadlessWebViewPortalSessionClient();
}

@riverpod
LoadPortalShortcutsUseCase loadPortalShortcutsUseCase(Ref ref) {
  return LoadPortalShortcutsUseCase(
    ref.watch(portalShortcutRepositoryProvider),
  );
}

@riverpod
RefreshPortalSessionUseCase refreshPortalSessionUseCase(Ref ref) {
  return RefreshPortalSessionUseCase(ref.watch(portalSessionClientProvider));
}
