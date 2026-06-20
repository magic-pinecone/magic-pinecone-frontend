// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NewsViewModel)
final newsViewModelProvider = NewsViewModelProvider._();

final class NewsViewModelProvider
    extends $AsyncNotifierProvider<NewsViewModel, NewsViewSnapshot> {
  NewsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newsViewModelHash();

  @$internal
  @override
  NewsViewModel create() => NewsViewModel();
}

String _$newsViewModelHash() => r'3903c63f72525622f781b50bb950459f422fa867';

abstract class _$NewsViewModel extends $AsyncNotifier<NewsViewSnapshot> {
  FutureOr<NewsViewSnapshot> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NewsViewSnapshot>, NewsViewSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NewsViewSnapshot>, NewsViewSnapshot>,
              AsyncValue<NewsViewSnapshot>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
