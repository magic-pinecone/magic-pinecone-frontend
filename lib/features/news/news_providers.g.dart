// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(newsDigestRepository)
final newsDigestRepositoryProvider = NewsDigestRepositoryProvider._();

final class NewsDigestRepositoryProvider
    extends
        $FunctionalProvider<
          NewsDigestRepository,
          NewsDigestRepository,
          NewsDigestRepository
        >
    with $Provider<NewsDigestRepository> {
  NewsDigestRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newsDigestRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newsDigestRepositoryHash();

  @$internal
  @override
  $ProviderElement<NewsDigestRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NewsDigestRepository create(Ref ref) {
    return newsDigestRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NewsDigestRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NewsDigestRepository>(value),
    );
  }
}

String _$newsDigestRepositoryHash() =>
    r'c3393ef83c0ffd25f327e89ff1ed4e9a6f74c0a4';

@ProviderFor(scholarshipApiService)
final scholarshipApiServiceProvider = ScholarshipApiServiceProvider._();

final class ScholarshipApiServiceProvider
    extends
        $FunctionalProvider<
          ScholarshipApiService,
          ScholarshipApiService,
          ScholarshipApiService
        >
    with $Provider<ScholarshipApiService> {
  ScholarshipApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scholarshipApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scholarshipApiServiceHash();

  @$internal
  @override
  $ProviderElement<ScholarshipApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScholarshipApiService create(Ref ref) {
    return scholarshipApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScholarshipApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScholarshipApiService>(value),
    );
  }
}

String _$scholarshipApiServiceHash() =>
    r'af1f140ff73104eadf2bc17e91184c6c73ff389b';

@ProviderFor(scholarshipRepository)
final scholarshipRepositoryProvider = ScholarshipRepositoryProvider._();

final class ScholarshipRepositoryProvider
    extends
        $FunctionalProvider<
          ScholarshipRepository,
          ScholarshipRepository,
          ScholarshipRepository
        >
    with $Provider<ScholarshipRepository> {
  ScholarshipRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scholarshipRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scholarshipRepositoryHash();

  @$internal
  @override
  $ProviderElement<ScholarshipRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScholarshipRepository create(Ref ref) {
    return scholarshipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScholarshipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScholarshipRepository>(value),
    );
  }
}

String _$scholarshipRepositoryHash() =>
    r'4397b9113e3938fb6728bff6bd4833fa8b841938';

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
