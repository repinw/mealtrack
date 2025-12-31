import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

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

sealed class InventoryDisplayItem extends Equatable {
  const InventoryDisplayItem();
}

class InventoryHeaderItem extends InventoryDisplayItem {
  final String storeName;
  final DateTime entryDate;
  final int itemCount;
  final String receiptId;
  final bool isFullyConsumed;

  const InventoryHeaderItem({
    required this.storeName,
    required this.entryDate,
    required this.itemCount,
    required this.receiptId,
    required this.isFullyConsumed,
  });

  @override
  List<Object?> get props => [
    storeName,
    entryDate,
    itemCount,
    receiptId,
    isFullyConsumed,
  ];
}

class InventoryProductItem extends InventoryDisplayItem {
  final String itemId;
  const InventoryProductItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class InventorySpacerItem extends InventoryDisplayItem {
  const InventorySpacerItem();

  @override
  List<Object?> get props => [];
}

@riverpod
AsyncValue<List<InventoryDisplayItem>> inventoryDisplayList(Ref ref) {
  final filterType = ref.watch(inventoryFilterProvider);
  final fridgeState = ref.watch(fridgeItemsProvider);

  return fridgeState.whenData((items) {
    if (items.isEmpty && filterType == InventoryFilterType.all) {
      return [];
    }

    final allGroups = <String, List<FridgeItem>>{};
    for (final item in items) {
      final key = item.receiptId ?? '';
      allGroups.putIfAbsent(key, () => []).add(item);
    }

    final displayList = <InventoryDisplayItem>[];
    final sortedKeys = allGroups.keys.toList();

    for (final key in sortedKeys) {
      final fullGroup = allGroups[key]!;

      final isFullyConsumed = fullGroup.every((item) => item.quantity == 0);

      final displayItems = fullGroup.where((item) {
        switch (filterType) {
          case InventoryFilterType.all:
            return true;
          case InventoryFilterType.available:
            return item.quantity > 0;
          case InventoryFilterType.empty:
            return item.quantity == 0;
        }
      }).toList();

      if (displayItems.isEmpty) continue;

      final first = fullGroup.first;

      displayList.add(
        InventoryHeaderItem(
          storeName: first.storeName,
          entryDate: first.entryDate,
          itemCount: displayItems.length,
          receiptId: key,
          isFullyConsumed: isFullyConsumed,
        ),
      );
      displayList.addAll(
        displayItems.map((item) => InventoryProductItem(item.id)),
      );
      displayList.add(const InventorySpacerItem());
    }

    return displayList;
  });
}
