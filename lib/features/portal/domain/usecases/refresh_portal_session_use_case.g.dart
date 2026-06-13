// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_portal_session_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
