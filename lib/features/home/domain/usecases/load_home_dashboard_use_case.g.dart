// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_home_dashboard_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(loadHomeDashboardUseCase)
final loadHomeDashboardUseCaseProvider = LoadHomeDashboardUseCaseProvider._();

final class LoadHomeDashboardUseCaseProvider
    extends
        $FunctionalProvider<
          LoadHomeDashboardUseCase,
          LoadHomeDashboardUseCase,
          LoadHomeDashboardUseCase
        >
    with $Provider<LoadHomeDashboardUseCase> {
  LoadHomeDashboardUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadHomeDashboardUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadHomeDashboardUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadHomeDashboardUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadHomeDashboardUseCase create(Ref ref) {
    return loadHomeDashboardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadHomeDashboardUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadHomeDashboardUseCase>(value),
    );
  }
}

String _$loadHomeDashboardUseCaseHash() =>
    r'2f7bfda7c8c7cdd848518fa6d8a0f7f3cda0bcb8';
