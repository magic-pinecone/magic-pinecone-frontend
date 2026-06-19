// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(portalShortcutRepository)
final portalShortcutRepositoryProvider = PortalShortcutRepositoryProvider._();

final class PortalShortcutRepositoryProvider
    extends
        $FunctionalProvider<
          PortalShortcutRepository,
          PortalShortcutRepository,
          PortalShortcutRepository
        >
    with $Provider<PortalShortcutRepository> {
  PortalShortcutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portalShortcutRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portalShortcutRepositoryHash();

  @$internal
  @override
  $ProviderElement<PortalShortcutRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PortalShortcutRepository create(Ref ref) {
    return portalShortcutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PortalShortcutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PortalShortcutRepository>(value),
    );
  }
}

String _$portalShortcutRepositoryHash() =>
    r'60328b79ecf06b205117386f3de9986319485657';

@ProviderFor(portalAuthenticator)
final portalAuthenticatorProvider = PortalAuthenticatorProvider._();

final class PortalAuthenticatorProvider
    extends
        $FunctionalProvider<
          PortalAuthenticator,
          PortalAuthenticator,
          PortalAuthenticator
        >
    with $Provider<PortalAuthenticator> {
  PortalAuthenticatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portalAuthenticatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portalAuthenticatorHash();

  @$internal
  @override
  $ProviderElement<PortalAuthenticator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PortalAuthenticator create(Ref ref) {
    return portalAuthenticator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PortalAuthenticator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PortalAuthenticator>(value),
    );
  }
}

String _$portalAuthenticatorHash() =>
    r'31a143f466c541b97e9c829f8beea53f0c7106ff';

@ProviderFor(loadPortalShortcutsUseCase)
final loadPortalShortcutsUseCaseProvider =
    LoadPortalShortcutsUseCaseProvider._();

final class LoadPortalShortcutsUseCaseProvider
    extends
        $FunctionalProvider<
          LoadPortalShortcutsUseCase,
          LoadPortalShortcutsUseCase,
          LoadPortalShortcutsUseCase
        >
    with $Provider<LoadPortalShortcutsUseCase> {
  LoadPortalShortcutsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadPortalShortcutsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadPortalShortcutsUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadPortalShortcutsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadPortalShortcutsUseCase create(Ref ref) {
    return loadPortalShortcutsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadPortalShortcutsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadPortalShortcutsUseCase>(value),
    );
  }
}

String _$loadPortalShortcutsUseCaseHash() =>
    r'4e873dcdb74e2eeadc5c361ab922e1ba1e7f640f';

@ProviderFor(refreshPortalSessionUseCase)
final refreshPortalSessionUseCaseProvider =
    RefreshPortalSessionUseCaseProvider._();

final class RefreshPortalSessionUseCaseProvider
    extends
        $FunctionalProvider<
          RefreshPortalSessionUseCase,
          RefreshPortalSessionUseCase,
          RefreshPortalSessionUseCase
        >
    with $Provider<RefreshPortalSessionUseCase> {
  RefreshPortalSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshPortalSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshPortalSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<RefreshPortalSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RefreshPortalSessionUseCase create(Ref ref) {
    return refreshPortalSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshPortalSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshPortalSessionUseCase>(value),
    );
  }
}

String _$refreshPortalSessionUseCaseHash() =>
    r'f677150d56ab11fd460052a34ed230ad48f19819';
