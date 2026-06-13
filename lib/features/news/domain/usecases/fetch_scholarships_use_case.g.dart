// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_scholarships_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fetchScholarshipsUseCase)
final fetchScholarshipsUseCaseProvider = FetchScholarshipsUseCaseProvider._();

final class FetchScholarshipsUseCaseProvider
    extends
        $FunctionalProvider<
          FetchScholarshipsUseCase,
          FetchScholarshipsUseCase,
          FetchScholarshipsUseCase
        >
    with $Provider<FetchScholarshipsUseCase> {
  FetchScholarshipsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchScholarshipsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchScholarshipsUseCaseHash();

  @$internal
  @override
  $ProviderElement<FetchScholarshipsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FetchScholarshipsUseCase create(Ref ref) {
    return fetchScholarshipsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FetchScholarshipsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FetchScholarshipsUseCase>(value),
    );
  }
}

String _$fetchScholarshipsUseCaseHash() =>
    r'a55c17e53c812a3a570bba93b71a5be8bfca6928';
