// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portal_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(portalShortcutSections)
final portalShortcutSectionsProvider = PortalShortcutSectionsProvider._();

final class PortalShortcutSectionsProvider
    extends
        $FunctionalProvider<
          List<PortalShortcutSection>,
          List<PortalShortcutSection>,
          List<PortalShortcutSection>
        >
    with $Provider<List<PortalShortcutSection>> {
  PortalShortcutSectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portalShortcutSectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portalShortcutSectionsHash();

  @$internal
  @override
  $ProviderElement<List<PortalShortcutSection>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PortalShortcutSection> create(Ref ref) {
    return portalShortcutSections(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PortalShortcutSection> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PortalShortcutSection>>(value),
    );
  }
}

String _$portalShortcutSectionsHash() =>
    r'2de93b82654ba8ee0624a59a3a3f31d9b1cfbcf2';

@ProviderFor(PortalSessionController)
final portalSessionControllerProvider = PortalSessionControllerProvider._();

final class PortalSessionControllerProvider
    extends $NotifierProvider<PortalSessionController, PortalSessionState> {
  PortalSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portalSessionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portalSessionControllerHash();

  @$internal
  @override
  PortalSessionController create() => PortalSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PortalSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PortalSessionState>(value),
    );
  }
}

String _$portalSessionControllerHash() =>
    r'1143bbb6b5e0e9fcdbdfd8173c9831e849f3ce67';

abstract class _$PortalSessionController extends $Notifier<PortalSessionState> {
  PortalSessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PortalSessionState, PortalSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PortalSessionState, PortalSessionState>,
              PortalSessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
