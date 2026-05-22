import 'package:prototype/features/portal/data/portal_shortcut_catalog.dart';
import 'package:prototype/features/portal/models/portal_shortcut.dart';

abstract class PortalShortcutRepository {
  List<PortalShortcutSection> loadShortcutSections();
}

class StaticPortalShortcutRepository implements PortalShortcutRepository {
  const StaticPortalShortcutRepository();

  @override
  List<PortalShortcutSection> loadShortcutSections() {
    return defaultPortalShortcutSections;
  }
}
