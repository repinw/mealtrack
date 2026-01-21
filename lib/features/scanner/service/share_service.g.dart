// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'share_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(receiveSharingIntent)
const receiveSharingIntentProvider = ReceiveSharingIntentProvider._();

final class ReceiveSharingIntentProvider
    extends
        $FunctionalProvider<
          ReceiveSharingIntent,
          ReceiveSharingIntent,
          ReceiveSharingIntent
        >
    with $Provider<ReceiveSharingIntent> {
  const ReceiveSharingIntentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiveSharingIntentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiveSharingIntentHash();

  @$internal
  @override
  $ProviderElement<ReceiveSharingIntent> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReceiveSharingIntent create(Ref ref) {
    return receiveSharingIntent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiveSharingIntent value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiveSharingIntent>(value),
    );
  }
}

String _$receiveSharingIntentHash() =>
    r'e49894760f4eac458ad6831d1b70e7aaff1a368b';

@ProviderFor(ShareService)
const shareServiceProvider = ShareServiceProvider._();

final class ShareServiceProvider
    extends $AsyncNotifierProvider<ShareService, void> {
  const ShareServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareServiceHash();

  @$internal
  @override
  ShareService create() => ShareService();
}

String _$shareServiceHash() => r'a2485c9ae6c33c689e5ea4099bb08c0366ddeb06';

abstract class _$ShareService extends $AsyncNotifier<void> {
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

@ProviderFor(LatestSharedFile)
const latestSharedFileProvider = LatestSharedFileProvider._();

final class LatestSharedFileProvider
    extends $NotifierProvider<LatestSharedFile, XFile?> {
  const LatestSharedFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestSharedFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestSharedFileHash();

  @$internal
  @override
  LatestSharedFile create() => LatestSharedFile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(XFile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<XFile?>(value),
    );
  }
}

String _$latestSharedFileHash() => r'852da53d10165dcebb4608e603db996ad1da8d86';

abstract class _$LatestSharedFile extends $Notifier<XFile?> {
  XFile? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<XFile?, XFile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<XFile?, XFile?>,
              XFile?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
