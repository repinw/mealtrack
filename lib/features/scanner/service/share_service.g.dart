// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'share_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$shareServiceHash() => r'8681410b554d31169cf0e5d7a79f876b44c88b5d';

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

String _$latestSharedFileHash() => r'd6954c084fbdfd03992a0b03ca20ed28d3d87b02';

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
