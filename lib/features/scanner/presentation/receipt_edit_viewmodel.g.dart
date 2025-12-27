// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_edit_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReceiptEditViewModel)
const receiptEditViewModelProvider = ReceiptEditViewModelProvider._();

final class ReceiptEditViewModelProvider
    extends $NotifierProvider<ReceiptEditViewModel, ReceiptEditState> {
  const ReceiptEditViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptEditViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptEditViewModelHash();

  @$internal
  @override
  ReceiptEditViewModel create() => ReceiptEditViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptEditState>(value),
    );
  }
}

String _$receiptEditViewModelHash() =>
    r'c37d8cf0d1e40609bf3e7eadcd6824302804f050';

abstract class _$ReceiptEditViewModel extends $Notifier<ReceiptEditState> {
  ReceiptEditState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ReceiptEditState, ReceiptEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReceiptEditState, ReceiptEditState>,
              ReceiptEditState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
