// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

final class HomeViewModelProvider
    extends $NotifierProvider<HomeViewModel, HomeViewSnapshot> {
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  HomeViewModel create() => HomeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeViewSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeViewSnapshot>(value),
    );
  }
}

String _$homeViewModelHash() => r'e2cfda38f670730ccdce105ac0d69fdcf81eb67e';

abstract class _$HomeViewModel extends $Notifier<HomeViewSnapshot> {
  HomeViewSnapshot build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeViewSnapshot, HomeViewSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeViewSnapshot, HomeViewSnapshot>,
              HomeViewSnapshot,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
