// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'share_flow_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShareFlowController)
const shareFlowControllerProvider = ShareFlowControllerProvider._();

final class ShareFlowControllerProvider
    extends $NotifierProvider<ShareFlowController, ShareFlowState> {
  const ShareFlowControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareFlowControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareFlowControllerHash();

  @$internal
  @override
  ShareFlowController create() => ShareFlowController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareFlowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareFlowState>(value),
    );
  }
}

String _$shareFlowControllerHash() =>
    r'5db5aabb62d3523adfc93e48fdd4e427f484de0a';

abstract class _$ShareFlowController extends $Notifier<ShareFlowState> {
  ShareFlowState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ShareFlowState, ShareFlowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShareFlowState, ShareFlowState>,
              ShareFlowState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
