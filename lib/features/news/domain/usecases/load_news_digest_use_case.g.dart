// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_news_digest_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(loadNewsDigestUseCase)
final loadNewsDigestUseCaseProvider = LoadNewsDigestUseCaseProvider._();

final class LoadNewsDigestUseCaseProvider
    extends
        $FunctionalProvider<
          LoadNewsDigestUseCase,
          LoadNewsDigestUseCase,
          LoadNewsDigestUseCase
        >
    with $Provider<LoadNewsDigestUseCase> {
  LoadNewsDigestUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadNewsDigestUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadNewsDigestUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadNewsDigestUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadNewsDigestUseCase create(Ref ref) {
    return loadNewsDigestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadNewsDigestUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadNewsDigestUseCase>(value),
    );
  }
}

String _$loadNewsDigestUseCaseHash() =>
    r'871b90caf45c859ab51804b598bc59128c96576e';
