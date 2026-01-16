import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_display_item.dart';

part 'inventory_viewmodel.g.dart';

@riverpod
class InventoryViewModel extends _$InventoryViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> deleteAllItems() async {
    await ref.read(fridgeItemsProvider.notifier).deleteAll();
  }

  Future<void> deleteItem(String id) async {
    await ref.read(fridgeItemsProvider.notifier).deleteItem(id);
  }
}

@riverpod
AsyncValue<List<InventoryDisplayItem>> inventoryDisplayList(Ref ref) {
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

    final displayList = <InventoryDisplayItem>[];

    displayList.addAll(
      _buildGroupList(
        items: nonArchivedItems,
        areArchived: false,
        collapsedGroups: collapsedGroups.asData?.value ?? <String>{},
        filterType: filterType,
      ),
    );

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
          _buildGroupList(
            items: archivedItems,
            areArchived: true,
            collapsedGroups: collapsedGroups.asData?.value ?? <String>{},
            filterType: filterType,
          ),
        );
      }
    }

    return displayList;
  });
}

List<InventoryDisplayItem> _buildGroupList({
  required List<FridgeItem> items,
  required bool areArchived,
  required Set<String> collapsedGroups,
  required InventoryFilterType filterType,
}) {
  final displayList = <InventoryDisplayItem>[];
  final groups = <String, List<FridgeItem>>{};
  for (final item in items) {
    final key = item.receiptId ?? '';
    groups.putIfAbsent(key, () => []).add(item);
  }

  final sortedKeys = groups.keys.toList();

  for (final key in sortedKeys) {
    final group = groups[key]!;
    final first = group.first;
    final isCollapsed = collapsedGroups.contains(key);

    final displayItems = group.where((item) {
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

    if (displayItems.isEmpty && !areArchived) continue;

    final isFullyConsumed = group.every((item) => item.quantity == 0);

    displayList.add(
      InventoryHeaderItem(
        storeName: first.storeName,
        entryDate: first.entryDate,
        itemCount: group.length,
        receiptId: key,
        isFullyConsumed: isFullyConsumed,
        isArchived: areArchived,
        isCollapsed: isCollapsed,
      ),
    );

    if (!isCollapsed) {
      displayList.addAll(
        displayItems.map((item) => InventoryProductItem(item.id)),
      );
    }
    displayList.add(const InventorySpacerItem());
  }
  return displayList;
}
