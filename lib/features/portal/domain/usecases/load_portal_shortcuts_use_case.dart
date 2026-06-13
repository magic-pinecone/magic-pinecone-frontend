import 'package:magic_pinecone/core/app/app_providers.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_shortcut_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_portal_shortcuts_use_case.g.dart';

class LoadPortalShortcutsUseCase {
  const LoadPortalShortcutsUseCase(this._repository);

  final PortalShortcutRepository _repository;

  List<PortalShortcutSection> execute() {
    return _repository.loadShortcutSections();
  }
}

@riverpod
LoadPortalShortcutsUseCase loadPortalShortcutsUseCase(Ref ref) {
  return LoadPortalShortcutsUseCase(
    ref.watch(portalShortcutRepositoryProvider),
  );
}
