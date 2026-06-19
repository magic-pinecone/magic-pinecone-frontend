// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeDashboardRepository)
final homeDashboardRepositoryProvider = HomeDashboardRepositoryProvider._();

final class HomeDashboardRepositoryProvider
    extends
        $FunctionalProvider<
          HomeDashboardRepository,
          HomeDashboardRepository,
          HomeDashboardRepository
        >
    with $Provider<HomeDashboardRepository> {
  HomeDashboardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeDashboardRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeDashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeDashboardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeDashboardRepository create(Ref ref) {
    return homeDashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeDashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeDashboardRepository>(value),
    );
  }
}

String _$homeDashboardRepositoryHash() =>
    r'b7ef46a3140ecf02a842d96423bc5b81cdf8c0d8';

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
