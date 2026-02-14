import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/domain/inventory_stats.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/shared_preferences_provider.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/domain/inventory_display_item.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/shoppinglist/data/category_stats_repository.dart';

part 'inventory_providers.g.dart';

@riverpod
class FridgeItems extends _$FridgeItems {
  @override
  Stream<List<FridgeItem>> build() {
    final repository = ref.watch(fridgeRepositoryProvider);
    return repository.watchItems();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
  }

  Future<void> addItems(List<FridgeItem> items) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.addItems(items);
    ref.invalidateSelf();
  }

  Future<void> updateItem(FridgeItem item) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.updateItem(item);
    ref.invalidateSelf();
  }

  Future<void> updateQuantity(FridgeItem item, int delta) async {
    if (delta == 0) return;

    final previousList = state.asData?.value;
    if (previousList == null) return;

    final updatedItem = item.adjustQuantity(delta);
    state = AsyncValue.data(_replaceItemById(previousList, updatedItem));

    try {
      final repository = ref.read(fridgeRepositoryProvider);
      await repository.updateQuantity(item, delta);

      if (item.category != null) {
        final categoryStatsRepo = ref.read(categoryStatsRepositoryProvider);
        await categoryStatsRepo.increment(
          item.category,
          -delta,
          unitPrice: item.unitPrice,
          productName: item.name,
        );
      }
    } catch (e) {
      state = AsyncValue.data(previousList);
      rethrow;
    }
  }

  Future<void> updateAmount(
    FridgeItem item,
    double amountBase, {
    required FridgeItemRemovalType removalType,
    bool isUndo = false,
  }) async {
    if (amountBase <= fridgeItemAmountEpsilon) return;

    final previousList = state.asData?.value;
    if (previousList == null) return;

    FridgeItem currentItem = item;
    for (final candidate in previousList) {
      if (candidate.id == item.id) {
        currentItem = candidate;
        break;
      }
    }

    final signedDelta = isUndo ? amountBase : -amountBase;
    final updatedItem = currentItem.adjustAmount(
      amountDeltaBase: signedDelta,
      removalType: removalType,
    );
    state = AsyncValue.data(_replaceItemById(previousList, updatedItem));

    try {
      final repository = ref.read(fridgeRepositoryProvider);
      await repository.updateAmount(
        currentItem,
        amountDeltaBase: signedDelta,
        removalType: removalType,
      );

      final pieceDelta = updatedItem.quantity - currentItem.quantity;
      if (currentItem.category != null && pieceDelta != 0) {
        final categoryStatsRepo = ref.read(categoryStatsRepositoryProvider);
        await categoryStatsRepo.increment(
          currentItem.category,
          -pieceDelta,
          unitPrice: currentItem.unitPrice,
          productName: currentItem.name,
        );
      }
    } catch (e) {
      state = AsyncValue.data(previousList);
      rethrow;
    }
  }

  Future<void> deleteAll() async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.deleteAllItems();
    ref.invalidateSelf();
  }

  Future<void> deleteItem(String id) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.deleteItem(id);
    ref.invalidateSelf();
  }

  Future<void> deleteItemsByReceipt(String receiptId) async {
    final repository = ref.read(fridgeRepositoryProvider);
    final items = state.asData?.value ?? [];
    final itemsToDelete = items.where((i) => i.receiptId == receiptId).toList();
    // coverage:ignore-start
    for (final item in itemsToDelete) {
      await repository.deleteItem(item.id);
    }
    ref.invalidateSelf();
    // coverage:ignore-end
  }

  /// Archives all items with the given [receiptId] by setting isArchived to true.
  void archiveReceipt(String receiptId) {
    final previousList = state.asData?.value;
    if (previousList == null) return;

    // Check if the group is currently expanded
    final collapsedGroups =
        ref.read(collapsedReceiptGroupsProvider).asData?.value ?? <String>{};

    final isExpanded = !collapsedGroups.contains(receiptId);

    // Optimistic update - update UI immediately
    state = AsyncValue.data(
      _setArchivedForReceipt(
        previousList,
        receiptId: receiptId,
        isArchived: true,
      ),
    );

    if (isExpanded) {
      ref.read(collapsedReceiptGroupsProvider.notifier).collapse(receiptId);
    }

    final repository = ref.read(fridgeRepositoryProvider);
    final archivedItems = _updatedItemsForReceipt(
      previousList,
      receiptId: receiptId,
      isArchived: true,
    );

    repository.updateItemsBatch(archivedItems).catchError((e) {
      state = AsyncValue.data(previousList);
      if (isExpanded) {
        ref.read(collapsedReceiptGroupsProvider.notifier).expand(receiptId);
      }
      return null;
    });
  }

  void unarchiveReceipt(String receiptId) {
    final previousList = state.asData?.value;
    if (previousList == null) return;

    state = AsyncValue.data(
      _setArchivedForReceipt(
        previousList,
        receiptId: receiptId,
        isArchived: false,
      ),
    );

    ref.read(collapsedReceiptGroupsProvider.notifier).expand(receiptId);

    final repository = ref.read(fridgeRepositoryProvider);
    final unarchivedItems = _updatedItemsForReceipt(
      previousList,
      receiptId: receiptId,
      isArchived: false,
    );

    repository.updateItemsBatch(unarchivedItems).catchError((e) {
      state = AsyncValue.data(previousList);
      return null;
    });
  }

  List<FridgeItem> _replaceItemById(
    List<FridgeItem> items,
    FridgeItem updatedItem,
  ) {
    return [
      for (final current in items)
        if (current.id == updatedItem.id) updatedItem else current,
    ];
  }

  List<FridgeItem> _setArchivedForReceipt(
    List<FridgeItem> items, {
    required String receiptId,
    required bool isArchived,
  }) {
    return [
      for (final item in items)
        if (item.receiptId == receiptId)
          item.copyWith(isArchived: isArchived)
        else
          item,
    ];
  }

  List<FridgeItem> _updatedItemsForReceipt(
    List<FridgeItem> items, {
    required String receiptId,
    required bool isArchived,
  }) {
    return items
        .where((item) => item.receiptId == receiptId)
        .map((item) => item.copyWith(isArchived: isArchived))
        .toList();
  }
}

@riverpod
class ArchivedItemsExpanded extends _$ArchivedItemsExpanded {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
class CollapsedReceiptGroups extends _$CollapsedReceiptGroups {
  static const _storageKey = 'collapsed_receipt_groups';

  @override
  Future<Set<String>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final storedList = prefs.getStringList(_storageKey);
    return storedList?.toSet() ?? {};
  }

  Future<void> toggle(String receiptId) async {
    final currentState = state.asData?.value ?? <String>{};
    final newState = currentState.contains(receiptId)
        ? ({...currentState}..remove(receiptId))
        : ({...currentState, receiptId});
    state = AsyncValue.data(newState);
    await _persistState(newState);
  }

  Future<void> collapse(String receiptId) async {
    final currentState = state.asData?.value ?? <String>{};
    if (!currentState.contains(receiptId)) {
      final newState = {...currentState, receiptId};
      state = AsyncValue.data(newState);
      await _persistState(newState);
    }
  }

  Future<void> expand(String receiptId) async {
    final currentState = state.asData?.value ?? <String>{};
    if (currentState.contains(receiptId)) {
      final newState = {...currentState}..remove(receiptId);
      state = AsyncValue.data(newState);
      await _persistState(newState);
    }
  }

  Future<void> _persistState(Set<String> newState) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setStringList(_storageKey, newState.toList());
    } catch (_) {
      // Ignore persistence errors
    }
  }
}

@riverpod
class InventoryFilter extends _$InventoryFilter {
  @override
  InventoryFilterType build() => InventoryFilterType.available;

  void setFilter(InventoryFilterType type) => state = type;
}

final inventoryDisplayListProvider =
    Provider.autoDispose<AsyncValue<List<InventoryDisplayItem>>>((ref) {
      final filterType = ref.watch(inventoryFilterProvider);
      final fridgeState = ref.watch(fridgeItemsProvider);
      final isArchivedExpanded = ref.watch(archivedItemsExpandedProvider);
      final collapsedGroups = ref.watch(collapsedReceiptGroupsProvider);

      return fridgeState.whenData((items) {
        if (items.isEmpty && filterType == InventoryFilterType.all) {
          return [];
        }

        final nonArchivedItems = <FridgeItem>[];
        final archivedItems = <FridgeItem>[];

        for (final item in items) {
          if (item.isArchived) {
            archivedItems.add(item);
          } else {
            nonArchivedItems.add(item);
          }
        }

        final collapsedGroupIds = collapsedGroups.asData?.value ?? <String>{};
        final displayList = <InventoryDisplayItem>[
          ..._buildInventoryGroupList(
            items: nonArchivedItems,
            areArchived: false,
            collapsedGroups: collapsedGroupIds,
            filterType: filterType,
          ),
        ];

        if (filterType == InventoryFilterType.all && archivedItems.isNotEmpty) {
          final archivedReceiptIds = archivedItems
              .map((item) => item.receiptId ?? '')
              .toSet();

          displayList.add(
            InventoryArchivedSectionItem(
              archivedReceiptCount: archivedReceiptIds.length,
              isExpanded: isArchivedExpanded,
            ),
          );

          if (isArchivedExpanded) {
            displayList.addAll(
              _buildInventoryGroupList(
                items: archivedItems,
                areArchived: true,
                collapsedGroups: collapsedGroupIds,
                filterType: filterType,
              ),
            );
          }
        }

        return displayList;
      });
    });

List<InventoryDisplayItem> _buildInventoryGroupList({
  required List<FridgeItem> items,
  required bool areArchived,
  required Set<String> collapsedGroups,
  required InventoryFilterType filterType,
}) {
  final displayList = <InventoryDisplayItem>[];
  final groups = <String, List<FridgeItem>>{};

  final sortedItems = List<FridgeItem>.from(items)
    ..sort((a, b) {
      final dateA = a.receiptDate ?? a.entryDate;
      final dateB = b.receiptDate ?? b.entryDate;
      return dateB.compareTo(dateA);
    });

  for (final item in sortedItems) {
    final key = item.receiptId ?? '';
    groups.putIfAbsent(key, () => []).add(item);
  }

  for (final key in groups.keys) {
    final group = groups[key]!;
    final first = group.first;
    final isCollapsed = collapsedGroups.contains(key);

    final filteredItems = group.where((item) {
      if (areArchived) {
        return true;
      }

      switch (filterType) {
        case InventoryFilterType.all:
          return true;
        case InventoryFilterType.available:
          return item.quantity > 0;
        case InventoryFilterType.consumed:
          return item.quantity < item.initialQuantity;
      }
    }).toList();

    if (filteredItems.isEmpty && !areArchived) {
      continue;
    }

    final isFullyConsumed = group.every((item) => item.quantity == 0);

    displayList.add(
      InventoryHeaderItem(
        storeName: first.storeName,
        entryDate: first.receiptDate ?? first.entryDate,
        itemCount: group.length,
        receiptId: key,
        isFullyConsumed: isFullyConsumed,
        isArchived: areArchived,
        isCollapsed: isCollapsed,
      ),
    );

    if (!isCollapsed) {
      displayList.addAll(
        filteredItems.map((item) => InventoryProductItem(item.id)),
      );
    }

    displayList.add(const InventorySpacerItem());
  }

  return displayList;
}

@riverpod
Future<List<FridgeItem>> availableFridgeItems(Ref ref) async {
  final items = await ref.watch(fridgeItemsProvider.future);
  return items.where((item) => !item.isConsumed).toList();
}

@riverpod
Future<List<MapEntry<String, List<FridgeItem>>>> groupedFridgeItems(
  Ref ref,
) async {
  final items = await ref.watch(fridgeItemsProvider.future);
  final groupedMap = <String, List<FridgeItem>>{};

  for (final item in items) {
    final key = item.receiptId ?? '';
    if (!groupedMap.containsKey(key)) {
      groupedMap[key] = [];
    }
    groupedMap[key]!.add(item);
  }

  return groupedMap.entries.toList();
}

final _loadingItem = FridgeItem(
  id: 'loading',
  name: '', // Empty string for loading state
  quantity: 0,
  storeName: '',
  entryDate: DateTime(1970),
);

final fridgeItemProvider = Provider.autoDispose.family<FridgeItem, String>((
  ref,
  id,
) {
  return ref.watch(
    fridgeItemsProvider.select((state) {
      final items = state.asData?.value;
      if (items == null) return _loadingItem;

      try {
        return items.firstWhere(
          (element) => element.id == id,
          orElse: () => _loadingItem,
        );
        // coverage:ignore-start
      } catch (_) {
        return _loadingItem;
      }
      // coverage:ignore-end
    }),
  );
});

@riverpod
InventoryStats inventoryStats(Ref ref) {
  final itemsAsync = ref.watch(fridgeItemsProvider);

  if (!itemsAsync.hasValue) {
    return InventoryStats.empty;
  }

  final items = itemsAsync.value!;
  final activeItems = items.where((i) => !i.isConsumed).toList();

  final totalValue = activeItems.fold(0.0, (sum, i) => sum + i.totalPrice);

  final scanCount = activeItems
      .map((e) => e.receiptId)
      .where((e) => e != null && e.isNotEmpty)
      .toSet()
      .length;

  final articleCount = activeItems.fold(0, (sum, i) => sum + i.quantity);

  return InventoryStats(
    totalValue: totalValue,
    scanCount: scanCount,
    articleCount: articleCount,
  );
}
