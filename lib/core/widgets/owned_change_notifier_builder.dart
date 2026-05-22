import 'package:flutter/material.dart';

typedef OwnedChangeNotifierFactory<T extends ChangeNotifier> =
    T Function(BuildContext context);
typedef OwnedChangeNotifierReady<T extends ChangeNotifier> =
    void Function(T notifier);
typedef OwnedChangeNotifierWidgetBuilder<T extends ChangeNotifier> =
    Widget Function(BuildContext context, T notifier);

class OwnedChangeNotifierBuilder<T extends ChangeNotifier>
    extends StatefulWidget {
  const OwnedChangeNotifierBuilder({
    super.key,
    this.notifier,
    required this.create,
    this.onReady,
    required this.builder,
  });

  final T? notifier;
  final OwnedChangeNotifierFactory<T> create;
  final OwnedChangeNotifierReady<T>? onReady;
  final OwnedChangeNotifierWidgetBuilder<T> builder;

  @override
  State<OwnedChangeNotifierBuilder<T>> createState() =>
      _OwnedChangeNotifierBuilderState<T>();
}

class _OwnedChangeNotifierBuilderState<T extends ChangeNotifier>
    extends State<OwnedChangeNotifierBuilder<T>> {
  T? _notifier;
  late final bool _ownsNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_notifier != null) return;

    _ownsNotifier = widget.notifier == null;
    _notifier = widget.notifier ?? widget.create(context);
    final onReady = widget.onReady;
    if (onReady != null) {
      onReady(_notifier!);
    }
  }

  @override
  void dispose() {
    if (_ownsNotifier) {
      _notifier?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _notifier!);
  }
}
