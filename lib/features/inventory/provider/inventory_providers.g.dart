// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FridgeItems)
const fridgeItemsProvider = FridgeItemsProvider._();

final class FridgeItemsProvider
    extends $AsyncNotifierProvider<FridgeItems, List<FridgeItem>> {
  const FridgeItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fridgeItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fridgeItemsHash();

  @$internal
  @override
  FridgeItems create() => FridgeItems();
}

String _$fridgeItemsHash() => r'6bde401e8b9afebdb865d230f283bc851abc7deb';

abstract class _$FridgeItems extends $AsyncNotifier<List<FridgeItem>> {
  FutureOr<List<FridgeItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<FridgeItem>>, List<FridgeItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FridgeItem>>, List<FridgeItem>>,
              AsyncValue<List<FridgeItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(InventoryFilter)
const inventoryFilterProvider = InventoryFilterProvider._();

final class InventoryFilterProvider
    extends $NotifierProvider<InventoryFilter, bool> {
  const InventoryFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryFilterHash();

  @$internal
  @override
  InventoryFilter create() => InventoryFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$inventoryFilterHash() => r'6afd6e62ed9069d0a680e84bb8d0aad745f3bbbd';

abstract class _$InventoryFilter extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(availableFridgeItems)
const availableFridgeItemsProvider = AvailableFridgeItemsProvider._();

final class AvailableFridgeItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FridgeItem>>,
          List<FridgeItem>,
          FutureOr<List<FridgeItem>>
        >
    with $FutureModifier<List<FridgeItem>>, $FutureProvider<List<FridgeItem>> {
  const AvailableFridgeItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableFridgeItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableFridgeItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<FridgeItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FridgeItem>> create(Ref ref) {
    return availableFridgeItems(ref);
  }
}

String _$availableFridgeItemsHash() =>
    r'2c51d7bfcbb3b8a442300969f77db2e36bf4a199';

@ProviderFor(groupedFridgeItems)
const groupedFridgeItemsProvider = GroupedFridgeItemsProvider._();

final class GroupedFridgeItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MapEntry<String, List<FridgeItem>>>>,
          List<MapEntry<String, List<FridgeItem>>>,
          FutureOr<List<MapEntry<String, List<FridgeItem>>>>
        >
    with
        $FutureModifier<List<MapEntry<String, List<FridgeItem>>>>,
        $FutureProvider<List<MapEntry<String, List<FridgeItem>>>> {
  const GroupedFridgeItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupedFridgeItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupedFridgeItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<MapEntry<String, List<FridgeItem>>>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MapEntry<String, List<FridgeItem>>>> create(Ref ref) {
    return groupedFridgeItems(ref);
  }
}

String _$groupedFridgeItemsHash() =>
    r'8a52f63e4df18566330c6d4763a4b02cede18f14';
