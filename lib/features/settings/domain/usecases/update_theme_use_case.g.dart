// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_theme_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    r'd35faedce9888d7ea58bd3e6405aa0d7764f5918';
