import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/navigation/app_routes.dart';
import 'package:prototype/main.dart' as app;

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
}
