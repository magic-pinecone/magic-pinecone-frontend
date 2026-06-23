// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'e80a11ad3eb002da3c4e4fcf13d781a570062489';

@ProviderFor(loadSettingsUseCase)
final loadSettingsUseCaseProvider = LoadSettingsUseCaseProvider._();

final class LoadSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          LoadSettingsUseCase,
          LoadSettingsUseCase,
          LoadSettingsUseCase
        >
    with $Provider<LoadSettingsUseCase> {
  LoadSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadSettingsUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadSettingsUseCase create(Ref ref) {
    return loadSettingsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadSettingsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadSettingsUseCase>(value),
    );
  }
}

String _$loadSettingsUseCaseHash() =>
    r'f4adc88725f141bb49fa2885063d24d7612f48f0';

@ProviderFor(updateBackendUrlUseCase)
final updateBackendUrlUseCaseProvider = UpdateBackendUrlUseCaseProvider._();

final class UpdateBackendUrlUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateBackendUrlUseCase,
          UpdateBackendUrlUseCase,
          UpdateBackendUrlUseCase
        >
    with $Provider<UpdateBackendUrlUseCase> {
  UpdateBackendUrlUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateBackendUrlUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateBackendUrlUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateBackendUrlUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateBackendUrlUseCase create(Ref ref) {
    return updateBackendUrlUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateBackendUrlUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateBackendUrlUseCase>(value),
    );
  }
}

String _$updateBackendUrlUseCaseHash() =>
    r'a1e0af75b9e8170cac2a88da548d979db801b473';

@ProviderFor(updateThemeUseCase)
final updateThemeUseCaseProvider = UpdateThemeUseCaseProvider._();

final class UpdateThemeUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateThemeUseCase,
          UpdateThemeUseCase,
          UpdateThemeUseCase
        >
    with $Provider<UpdateThemeUseCase> {
  UpdateThemeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateThemeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateThemeUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateThemeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateThemeUseCase create(Ref ref) {
    return updateThemeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateThemeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateThemeUseCase>(value),
    );
  }
}

String _$updateThemeUseCaseHash() =>
    r'6bcb68325f9b308ecc25348c2b1f6938d69ee32b';
