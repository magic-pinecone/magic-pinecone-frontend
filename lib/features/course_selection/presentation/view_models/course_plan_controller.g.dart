// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_plan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CoursePlanController)
final coursePlanControllerProvider = CoursePlanControllerProvider._();

final class CoursePlanControllerProvider
    extends $NotifierProvider<CoursePlanController, CoursePlanState> {
  CoursePlanControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coursePlanControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coursePlanControllerHash();

  @$internal
  @override
  CoursePlanController create() => CoursePlanController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoursePlanState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoursePlanState>(value),
    );
  }
}

String _$coursePlanControllerHash() =>
    r'8d660810fdee4118ae6740eeef2c756bf482277c';

abstract class _$CoursePlanController extends $Notifier<CoursePlanState> {
  CoursePlanState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CoursePlanState, CoursePlanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CoursePlanState, CoursePlanState>,
              CoursePlanState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
