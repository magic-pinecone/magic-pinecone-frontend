// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_portal_shortcuts_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
