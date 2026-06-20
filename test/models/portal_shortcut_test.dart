import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/portal/domain/models/portal_shortcut.dart';

void main() {
  group('PortalWebShortcutDestination.buildTargetUrl', () {
    test('returns null when shortcut has no target path', () {
      const destination = PortalWebShortcutDestination(title: 'Missing link');

      expect(destination.buildTargetUrl(token: 'abc'), isNull);
    });

    test('builds url without token when token is empty', () {
      const destination = PortalWebShortcutDestination(
        title: 'Portal',
        targetPath: '/system/test',
      );

      final url = destination.buildTargetUrl(token: '   ');

      expect(url.toString(), 'https://portal.ncu.edu.tw/system/test');
    });

    test('builds url with trimmed token when token exists', () {
      const destination = PortalWebShortcutDestination(
        title: 'Portal',
        targetPath: '/system/test',
      );

      final url = destination.buildTargetUrl(token: ' token123 ');

      expect(
        url.toString(),
        'https://portal.ncu.edu.tw/system/test?token=token123',
      );
    });
  });
}
