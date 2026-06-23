// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_backend_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppBackendConfigController)
final appBackendConfigControllerProvider =
    AppBackendConfigControllerProvider._();

final class AppBackendConfigControllerProvider
    extends $NotifierProvider<AppBackendConfigController, String> {
  AppBackendConfigControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appBackendConfigControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appBackendConfigControllerHash();

  @$internal
  @override
  AppBackendConfigController create() => AppBackendConfigController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$appBackendConfigControllerHash() =>
    r'323b081ef9e24bd68a83269077a6869a2b4aa937';

abstract class _$AppBackendConfigController extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
