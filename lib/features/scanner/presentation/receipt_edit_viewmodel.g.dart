// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_edit_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReceiptEditViewModel)
const receiptEditViewModelProvider = ReceiptEditViewModelFamily._();

final class ReceiptEditViewModelProvider
    extends $NotifierProvider<ReceiptEditViewModel, ReceiptEditState> {
  const ReceiptEditViewModelProvider._({
    required ReceiptEditViewModelFamily super.from,
    required List<FridgeItem>? super.argument,
  }) : super(
         retry: null,
         name: r'receiptEditViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$receiptEditViewModelHash();

  @override
  String toString() {
    return r'receiptEditViewModelProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is ReceiptEditViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$receiptEditViewModelHash() =>
    r'6e6d32372f08481d0dd1c5d8b5a63777af1c8167';

final class ReceiptEditViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ReceiptEditViewModel,
          ReceiptEditState,
          ReceiptEditState,
          ReceiptEditState,
          List<FridgeItem>?
        > {
  const ReceiptEditViewModelFamily._()
    : super(
        retry: null,
        name: r'receiptEditViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReceiptEditViewModelProvider call(List<FridgeItem>? scannedItems) =>
      ReceiptEditViewModelProvider._(argument: scannedItems, from: this);

  @override
  String toString() => r'receiptEditViewModelProvider';
}

abstract class _$ReceiptEditViewModel extends $Notifier<ReceiptEditState> {
  late final _$args = ref.$arg as List<FridgeItem>?;
  List<FridgeItem>? get scannedItems => _$args;

  ReceiptEditState build(List<FridgeItem>? scannedItems);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
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
