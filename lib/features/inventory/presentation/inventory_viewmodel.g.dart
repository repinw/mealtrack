// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryViewModel)
const inventoryViewModelProvider = InventoryViewModelProvider._();

final class InventoryViewModelProvider
    extends $AsyncNotifierProvider<InventoryViewModel, void> {
  const InventoryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryViewModelHash();

  @$internal
  @override
  InventoryViewModel create() => InventoryViewModel();
}

String _$inventoryViewModelHash() =>
    r'77b221c0b71e95df29ee5f5bf90e9b85b69212e0';

abstract class _$InventoryViewModel extends $AsyncNotifier<void> {
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

@ProviderFor(inventoryDisplayList)
const inventoryDisplayListProvider = InventoryDisplayListProvider._();

final class InventoryDisplayListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InventoryDisplayItem>>,
          AsyncValue<List<InventoryDisplayItem>>,
          AsyncValue<List<InventoryDisplayItem>>
        >
    with $Provider<AsyncValue<List<InventoryDisplayItem>>> {
  const InventoryDisplayListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryDisplayListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryDisplayListHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<InventoryDisplayItem>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<InventoryDisplayItem>> create(Ref ref) {
    return inventoryDisplayList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<InventoryDisplayItem>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<InventoryDisplayItem>>>(value),
    );
  }
}

String _$inventoryDisplayListHash() =>
    r'2007a69c242dcd7209e410ae6f90de357d4c0665';
