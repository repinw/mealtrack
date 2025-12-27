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
    r'2afabfc67d26d24d2e73749824c3d23ae57a8679';
