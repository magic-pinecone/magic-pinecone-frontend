// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_courses_by_serial_nos_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
