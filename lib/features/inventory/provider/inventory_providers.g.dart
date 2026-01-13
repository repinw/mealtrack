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

String _$fridgeItemsHash() => r'f74daf36e683ffe11a8f70a3df858936c975c017';

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

@ProviderFor(ArchivedItemsExpanded)
const archivedItemsExpandedProvider = ArchivedItemsExpandedProvider._();

final class ArchivedItemsExpandedProvider
    extends $NotifierProvider<ArchivedItemsExpanded, bool> {
  const ArchivedItemsExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedItemsExpandedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedItemsExpandedHash();

  @$internal
  @override
  ArchivedItemsExpanded create() => ArchivedItemsExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$archivedItemsExpandedHash() =>
    r'82068764df2b20184803575ed6e50953246295bb';

abstract class _$ArchivedItemsExpanded extends $Notifier<bool> {
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

@ProviderFor(SavedReceiptExpansionState)
const savedReceiptExpansionStateProvider =
    SavedReceiptExpansionStateProvider._();

final class SavedReceiptExpansionStateProvider
    extends $NotifierProvider<SavedReceiptExpansionState, Map<String, bool>> {
  const SavedReceiptExpansionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedReceiptExpansionStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedReceiptExpansionStateHash();

  @$internal
  @override
  SavedReceiptExpansionState create() => SavedReceiptExpansionState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, bool>>(value),
    );
  }
}

String _$savedReceiptExpansionStateHash() =>
    r'085d74d8292a673191fdffbb484da0ac4e4de383';

abstract class _$SavedReceiptExpansionState
    extends $Notifier<Map<String, bool>> {
  Map<String, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<String, bool>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, bool>, Map<String, bool>>,
              Map<String, bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CollapsedReceiptGroups)
const collapsedReceiptGroupsProvider = CollapsedReceiptGroupsProvider._();

final class CollapsedReceiptGroupsProvider
    extends $NotifierProvider<CollapsedReceiptGroups, Set<String>> {
  const CollapsedReceiptGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collapsedReceiptGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collapsedReceiptGroupsHash();

  @$internal
  @override
  CollapsedReceiptGroups create() => CollapsedReceiptGroups();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$collapsedReceiptGroupsHash() =>
    r'80d66e0920e48d05df95d2ddf9a9c9b02ad04340';

abstract class _$CollapsedReceiptGroups extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
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
