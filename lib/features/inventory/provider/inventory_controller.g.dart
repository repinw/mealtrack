// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryController)
const inventoryControllerProvider = InventoryControllerProvider._();

final class InventoryControllerProvider
    extends $AsyncNotifierProvider<InventoryController, void> {
  const InventoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryControllerHash();

  @$internal
  @override
  InventoryController create() => InventoryController();
}

String _$inventoryControllerHash() =>
    r'b1192d04ddb931c7f1e2ab88cd9e485f0e526dad';

abstract class _$InventoryController extends $AsyncNotifier<void> {
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
          List<InventoryDisplayItem>,
          FutureOr<List<InventoryDisplayItem>>
        >
    with
        $FutureModifier<List<InventoryDisplayItem>>,
        $FutureProvider<List<InventoryDisplayItem>> {
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
  $FutureProviderElement<List<InventoryDisplayItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InventoryDisplayItem>> create(Ref ref) {
    return inventoryDisplayList(ref);
  }
}

String _$inventoryDisplayListHash() =>
    r'f8293b01645f06b1cff0f464d0d77a6cca104399';
