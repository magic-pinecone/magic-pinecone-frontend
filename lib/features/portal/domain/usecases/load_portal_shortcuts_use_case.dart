import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_shortcut_repository.dart';

class LoadPortalShortcutsUseCase {
  const LoadPortalShortcutsUseCase(this._repository);

  final PortalShortcutRepository _repository;

  List<PortalShortcutSection> execute() {
    return _repository.loadShortcutSections();
  }
}
