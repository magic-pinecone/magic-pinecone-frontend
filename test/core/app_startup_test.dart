import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/core/navigation/app_navigation_state.dart';
import 'package:magic_pinecone/core/navigation/app_routes.dart';
import 'package:magic_pinecone/main.dart' as app;

void main() {
  test('share links start on course selection tab', () {
    final uri = Uri.parse('https://example.com/share?c=abc123');

    expect(app.courseShareCodeFromUri(uri), 'abc123');
    expect(app.initialAppTabForUri(uri), AppTab.courseSelection);
  });

  test('normal links start on home tab', () {
    final uri = Uri.parse('https://example.com/');

    expect(app.courseShareCodeFromUri(uri), isNull);
    expect(app.initialAppTabForUri(uri), AppTab.home);
  });

  test('active app tab provider stores bottom navigation state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(activeAppTabProvider), AppTab.home);

    container.read(activeAppTabProvider.notifier).setTab(AppTab.settings);

    expect(container.read(activeAppTabProvider), AppTab.settings);
  });
}
