// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_navigation_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(initialActiveAppTab)
final initialActiveAppTabProvider = InitialActiveAppTabProvider._();

final class InitialActiveAppTabProvider
    extends $FunctionalProvider<AppTab, AppTab, AppTab>
    with $Provider<AppTab> {
  InitialActiveAppTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialActiveAppTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialActiveAppTabHash();

  @$internal
  @override
  $ProviderElement<AppTab> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppTab create(Ref ref) {
    return initialActiveAppTab(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppTab>(value),
    );
  }
}

String _$initialActiveAppTabHash() =>
    r'0613b43628781b82837ef6ca3800ddebb2694353';

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

String _$activeAppTabHash() => r'8ff01e89cc52deb3b5824d9fbf7b1f915ac35de1';

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
