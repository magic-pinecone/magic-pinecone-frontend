// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_settings_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
