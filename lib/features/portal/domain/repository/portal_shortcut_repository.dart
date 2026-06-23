import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';

abstract class PortalShortcutRepository {
  List<PortalShortcutSection> loadShortcutSections();
}
