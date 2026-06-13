// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_backend_url_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    r'd60e93f0b08b3ed16e31faa0dc94e63960ef82cc';
