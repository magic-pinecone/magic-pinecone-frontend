// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_selection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CourseSelectionController)
final courseSelectionControllerProvider = CourseSelectionControllerProvider._();

final class CourseSelectionControllerProvider
    extends $NotifierProvider<CourseSelectionController, CourseSelectionState> {
  CourseSelectionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseSelectionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseSelectionControllerHash();

  @$internal
  @override
  CourseSelectionController create() => CourseSelectionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourseSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourseSelectionState>(value),
    );
  }
}

String _$courseSelectionControllerHash() =>
    r'1a800bec0993060912f3d8eb00dc2e85dd83cda3';

abstract class _$CourseSelectionController
    extends $Notifier<CourseSelectionState> {
  CourseSelectionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CourseSelectionState, CourseSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CourseSelectionState, CourseSelectionState>,
              CourseSelectionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
