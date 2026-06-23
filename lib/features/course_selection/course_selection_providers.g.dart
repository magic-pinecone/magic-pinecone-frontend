// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_selection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(courseApiService)
final courseApiServiceProvider = CourseApiServiceProvider._();

final class CourseApiServiceProvider
    extends
        $FunctionalProvider<
          CourseApiService,
          CourseApiService,
          CourseApiService
        >
    with $Provider<CourseApiService> {
  CourseApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseApiServiceHash();

  @$internal
  @override
  $ProviderElement<CourseApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CourseApiService create(Ref ref) {
    return courseApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourseApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourseApiService>(value),
    );
  }
}

String _$courseApiServiceHash() => r'385cb990aa58ba398bf7a212926720d44390d4a2';

@ProviderFor(staticCourseCatalogDataSource)
final staticCourseCatalogDataSourceProvider =
    StaticCourseCatalogDataSourceProvider._();

final class StaticCourseCatalogDataSourceProvider
    extends
        $FunctionalProvider<
          StaticCourseCatalogDataSource,
          StaticCourseCatalogDataSource,
          StaticCourseCatalogDataSource
        >
    with $Provider<StaticCourseCatalogDataSource> {
  StaticCourseCatalogDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'staticCourseCatalogDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$staticCourseCatalogDataSourceHash();

  @$internal
  @override
  $ProviderElement<StaticCourseCatalogDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StaticCourseCatalogDataSource create(Ref ref) {
    return staticCourseCatalogDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StaticCourseCatalogDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StaticCourseCatalogDataSource>(
        value,
      ),
    );
  }
}

String _$staticCourseCatalogDataSourceHash() =>
    r'32db054ca820a341236ae1a527be8809960b1953';

@ProviderFor(backendCourseRepository)
final backendCourseRepositoryProvider = BackendCourseRepositoryProvider._();

final class BackendCourseRepositoryProvider
    extends
        $FunctionalProvider<
          CourseRepository,
          CourseRepository,
          CourseRepository
        >
    with $Provider<CourseRepository> {
  BackendCourseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backendCourseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backendCourseRepositoryHash();

  @$internal
  @override
  $ProviderElement<CourseRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CourseRepository create(Ref ref) {
    return backendCourseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourseRepository>(value),
    );
  }
}

String _$backendCourseRepositoryHash() =>
    r'760c45c0649e64880464455b192b6c150da2379b';

@ProviderFor(courseRepository)
final courseRepositoryProvider = CourseRepositoryProvider._();

final class CourseRepositoryProvider
    extends
        $FunctionalProvider<
          CourseRepository,
          CourseRepository,
          CourseRepository
        >
    with $Provider<CourseRepository> {
  CourseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseRepositoryHash();

  @$internal
  @override
  $ProviderElement<CourseRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CourseRepository create(Ref ref) {
    return courseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourseRepository>(value),
    );
  }
}

String _$courseRepositoryHash() => r'2e5e252f69ae3ba1cc432ef931467666dc3e533f';

@ProviderFor(courseSupplementalDetailRepository)
final courseSupplementalDetailRepositoryProvider =
    CourseSupplementalDetailRepositoryProvider._();

final class CourseSupplementalDetailRepositoryProvider
    extends
        $FunctionalProvider<
          CourseSupplementalDetailRepository,
          CourseSupplementalDetailRepository,
          CourseSupplementalDetailRepository
        >
    with $Provider<CourseSupplementalDetailRepository> {
  CourseSupplementalDetailRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseSupplementalDetailRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$courseSupplementalDetailRepositoryHash();

  @$internal
  @override
  $ProviderElement<CourseSupplementalDetailRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CourseSupplementalDetailRepository create(Ref ref) {
    return courseSupplementalDetailRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourseSupplementalDetailRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourseSupplementalDetailRepository>(
        value,
      ),
    );
  }
}

String _$courseSupplementalDetailRepositoryHash() =>
    r'6bfe9cec527d48e617a0e7e98f89d8880a3e1d62';

@ProviderFor(courseSelectionStorage)
final courseSelectionStorageProvider = CourseSelectionStorageProvider._();

final class CourseSelectionStorageProvider
    extends
        $FunctionalProvider<
          CourseSelectionStorage,
          CourseSelectionStorage,
          CourseSelectionStorage
        >
    with $Provider<CourseSelectionStorage> {
  CourseSelectionStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseSelectionStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseSelectionStorageHash();

  @$internal
  @override
  $ProviderElement<CourseSelectionStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CourseSelectionStorage create(Ref ref) {
    return courseSelectionStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourseSelectionStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourseSelectionStorage>(value),
    );
  }
}

String _$courseSelectionStorageHash() =>
    r'ac325d4726cbf75dd6464b2c97c2f028f2ac7bd4';

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

@ProviderFor(coursePlanScheduleBuilder)
final coursePlanScheduleBuilderProvider = CoursePlanScheduleBuilderProvider._();

final class CoursePlanScheduleBuilderProvider
    extends
        $FunctionalProvider<
          CoursePlanScheduleBuilder,
          CoursePlanScheduleBuilder,
          CoursePlanScheduleBuilder
        >
    with $Provider<CoursePlanScheduleBuilder> {
  CoursePlanScheduleBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coursePlanScheduleBuilderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coursePlanScheduleBuilderHash();

  @$internal
  @override
  $ProviderElement<CoursePlanScheduleBuilder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CoursePlanScheduleBuilder create(Ref ref) {
    return coursePlanScheduleBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoursePlanScheduleBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoursePlanScheduleBuilder>(value),
    );
  }
}

String _$coursePlanScheduleBuilderHash() =>
    r'b6871ec452351e43a454a42b8029a4a6675e39a7';

@ProviderFor(findCoursesBySerialNosUseCase)
final findCoursesBySerialNosUseCaseProvider =
    FindCoursesBySerialNosUseCaseProvider._();

final class FindCoursesBySerialNosUseCaseProvider
    extends
        $FunctionalProvider<
          FindCoursesBySerialNosUseCase,
          FindCoursesBySerialNosUseCase,
          FindCoursesBySerialNosUseCase
        >
    with $Provider<FindCoursesBySerialNosUseCase> {
  FindCoursesBySerialNosUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findCoursesBySerialNosUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findCoursesBySerialNosUseCaseHash();

  @$internal
  @override
  $ProviderElement<FindCoursesBySerialNosUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FindCoursesBySerialNosUseCase create(Ref ref) {
    return findCoursesBySerialNosUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FindCoursesBySerialNosUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FindCoursesBySerialNosUseCase>(
        value,
      ),
    );
  }
}

String _$findCoursesBySerialNosUseCaseHash() =>
    r'5b3ba4f1ed32e918709ab268ab16ceb13ce2f9d6';
