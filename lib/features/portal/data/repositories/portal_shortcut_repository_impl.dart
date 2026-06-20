import 'package:magic_pinecone/features/portal/data/data_sources/portal_shortcut_catalog.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';
import 'package:magic_pinecone/features/portal/domain/repository/portal_shortcut_repository.dart';

class StaticPortalShortcutRepository implements PortalShortcutRepository {
  const StaticPortalShortcutRepository();

  @override
  List<PortalShortcutSection> loadShortcutSections() {
    return defaultPortalShortcutSections;
  }
}
