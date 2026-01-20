// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'guest_name_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GuestNameViewModel)
const guestNameViewModelProvider = GuestNameViewModelProvider._();

final class GuestNameViewModelProvider
    extends $NotifierProvider<GuestNameViewModel, AsyncValue<void>> {
  const GuestNameViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guestNameViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guestNameViewModelHash();

  @$internal
  @override
  GuestNameViewModel create() => GuestNameViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$guestNameViewModelHash() =>
    r'618839d190811378acdd2f6c0fe7a4967d360c86';

abstract class _$GuestNameViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
