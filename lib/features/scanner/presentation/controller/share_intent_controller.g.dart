// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'share_intent_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShareIntentController)
const shareIntentControllerProvider = ShareIntentControllerProvider._();

final class ShareIntentControllerProvider
    extends $AsyncNotifierProvider<ShareIntentController, void> {
  const ShareIntentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareIntentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareIntentControllerHash();

  @$internal
  @override
  ShareIntentController create() => ShareIntentController();
}

String _$shareIntentControllerHash() =>
    r'ba61dd23d1b9578dac59ad1ed335ca252b90362d';

abstract class _$ShareIntentController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
