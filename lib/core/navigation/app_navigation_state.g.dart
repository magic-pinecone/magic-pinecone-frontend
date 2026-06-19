// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_navigation_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveAppTab)
final activeAppTabProvider = ActiveAppTabProvider._();

final class ActiveAppTabProvider
    extends $NotifierProvider<ActiveAppTab, AppTab> {
  ActiveAppTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeAppTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeAppTabHash();

  @$internal
  @override
  ActiveAppTab create() => ActiveAppTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppTab>(value),
    );
  }
}

String _$activeAppTabHash() => r'eebccfd87b451f41452319d2fdeb57bd98d05059';

abstract class _$ActiveAppTab extends $Notifier<AppTab> {
  AppTab build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppTab, AppTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppTab, AppTab>,
              AppTab,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
