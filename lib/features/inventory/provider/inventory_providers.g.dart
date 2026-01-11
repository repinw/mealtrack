// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FridgeItems)
const fridgeItemsProvider = FridgeItemsProvider._();

final class FridgeItemsProvider
    extends $StreamNotifierProvider<FridgeItems, List<FridgeItem>> {
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

String _$fridgeItemsHash() => r'6a9d51ab0f43c7c57d057b6eae7c0780405d7534';

abstract class _$FridgeItems extends $StreamNotifier<List<FridgeItem>> {
  Stream<List<FridgeItem>> build();
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
    extends $NotifierProvider<InventoryFilter, InventoryFilterType> {
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
  Override overrideWithValue(InventoryFilterType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryFilterType>(value),
    );
  }
}

String _$inventoryFilterHash() => r'90a568eeb7bfad6f5d78679887e7c6ba6003b0bc';

abstract class _$InventoryFilter extends $Notifier<InventoryFilterType> {
  InventoryFilterType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<InventoryFilterType, InventoryFilterType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InventoryFilterType, InventoryFilterType>,
              InventoryFilterType,
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

@ProviderFor(inventoryStats)
const inventoryStatsProvider = InventoryStatsProvider._();

final class InventoryStatsProvider
    extends $FunctionalProvider<InventoryStats, InventoryStats, InventoryStats>
    with $Provider<InventoryStats> {
  const InventoryStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryStatsHash();

  @$internal
  @override
  $ProviderElement<InventoryStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InventoryStats create(Ref ref) {
    return inventoryStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryStats>(value),
    );
  }
}

String _$inventoryStatsHash() => r'314bf143a4d50f6fcd8beba5403f4ea90d34b364';
