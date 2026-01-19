// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'sharing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SharingViewModel)
const sharingViewModelProvider = SharingViewModelProvider._();

final class SharingViewModelProvider
    extends $NotifierProvider<SharingViewModel, AsyncValue<String?>> {
  const SharingViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharingViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharingViewModelHash();

  @$internal
  @override
  SharingViewModel create() => SharingViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$sharingViewModelHash() => r'347ad4fae057c27f5ac21b996c253356fe7427c9';

abstract class _$SharingViewModel extends $Notifier<AsyncValue<String?>> {
  AsyncValue<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String?>, AsyncValue<String?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, AsyncValue<String?>>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
