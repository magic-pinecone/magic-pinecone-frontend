// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'3d1d6049ac74d0e218e8a412a5343f94c89ecf48';

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

String _$courseRepositoryHash() => r'd0f2af42ef9eeab6968962d4be8c687cce5020e6';

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

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'e80a11ad3eb002da3c4e4fcf13d781a570062489';

@ProviderFor(homeDashboardRepository)
final homeDashboardRepositoryProvider = HomeDashboardRepositoryProvider._();

final class HomeDashboardRepositoryProvider
    extends
        $FunctionalProvider<
          HomeDashboardRepository,
          HomeDashboardRepository,
          HomeDashboardRepository
        >
    with $Provider<HomeDashboardRepository> {
  HomeDashboardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeDashboardRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeDashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeDashboardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeDashboardRepository create(Ref ref) {
    return homeDashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeDashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeDashboardRepository>(value),
    );
  }
}

String _$homeDashboardRepositoryHash() =>
    r'b7ef46a3140ecf02a842d96423bc5b81cdf8c0d8';

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

@ProviderFor(portalShortcutRepository)
final portalShortcutRepositoryProvider = PortalShortcutRepositoryProvider._();

final class PortalShortcutRepositoryProvider
    extends
        $FunctionalProvider<
          PortalShortcutRepository,
          PortalShortcutRepository,
          PortalShortcutRepository
        >
    with $Provider<PortalShortcutRepository> {
  PortalShortcutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portalShortcutRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portalShortcutRepositoryHash();

  @$internal
  @override
  $ProviderElement<PortalShortcutRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PortalShortcutRepository create(Ref ref) {
    return portalShortcutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PortalShortcutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PortalShortcutRepository>(value),
    );
  }
}

String _$portalShortcutRepositoryHash() =>
    r'60328b79ecf06b205117386f3de9986319485657';

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

@ProviderFor(portalAuthenticator)
final portalAuthenticatorProvider = PortalAuthenticatorProvider._();

final class PortalAuthenticatorProvider
    extends
        $FunctionalProvider<
          PortalAuthenticator,
          PortalAuthenticator,
          PortalAuthenticator
        >
    with $Provider<PortalAuthenticator> {
  PortalAuthenticatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portalAuthenticatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portalAuthenticatorHash();

  @$internal
  @override
  $ProviderElement<PortalAuthenticator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PortalAuthenticator create(Ref ref) {
    return portalAuthenticator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PortalAuthenticator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PortalAuthenticator>(value),
    );
  }
}

String _$portalAuthenticatorHash() =>
    r'31a143f466c541b97e9c829f8beea53f0c7106ff';
