// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_courses_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchCoursesUseCase)
final searchCoursesUseCaseProvider = SearchCoursesUseCaseProvider._();

final class SearchCoursesUseCaseProvider
    extends
        $FunctionalProvider<
          SearchCoursesUseCase,
          SearchCoursesUseCase,
          SearchCoursesUseCase
        >
    with $Provider<SearchCoursesUseCase> {
  SearchCoursesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchCoursesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchCoursesUseCaseHash();

  @$internal
  @override
  $ProviderElement<SearchCoursesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchCoursesUseCase create(Ref ref) {
    return searchCoursesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchCoursesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchCoursesUseCase>(value),
    );
  }
}

String _$searchCoursesUseCaseHash() =>
    r'58b9ce13628900746b2a4dc38898cdd92d07fbf1';
