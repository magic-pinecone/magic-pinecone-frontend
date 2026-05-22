import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype/core/widgets/owned_change_notifier_builder.dart';

void main() {
  testWidgets(
    'OwnedChangeNotifierBuilder initializes and disposes owned notifier',
    (tester) async {
      final created = <FakeNotifier>[];

      await tester.pumpWidget(
        MaterialApp(
          home: OwnedChangeNotifierBuilder<FakeNotifier>(
            create: (_) {
              final notifier = FakeNotifier();
              created.add(notifier);
              return notifier;
            },
            onReady: (notifier) => notifier.markReady(),
            builder: (_, notifier) => Text('ready:${notifier.readyCount}'),
          ),
        ),
      );

      expect(find.text('ready:1'), findsOneWidget);
      expect(created.single.wasDisposed, isFalse);

      await tester.pumpWidget(const SizedBox.shrink());

      expect(created.single.wasDisposed, isTrue);
    },
  );

  testWidgets('OwnedChangeNotifierBuilder does not dispose injected notifier', (
    tester,
  ) async {
    final notifier = FakeNotifier();

    await tester.pumpWidget(
      MaterialApp(
        home: OwnedChangeNotifierBuilder<FakeNotifier>(
          notifier: notifier,
          create: (_) => FakeNotifier(),
          onReady: (notifier) => notifier.markReady(),
          builder: (_, notifier) => Text('ready:${notifier.readyCount}'),
        ),
      ),
    );

    expect(find.text('ready:1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(notifier.wasDisposed, isFalse);
  });
}

class FakeNotifier extends ChangeNotifier {
  int readyCount = 0;
  bool wasDisposed = false;

  void markReady() {
    readyCount += 1;
  }

  @override
  void dispose() {
    wasDisposed = true;
    super.dispose();
  }
}
