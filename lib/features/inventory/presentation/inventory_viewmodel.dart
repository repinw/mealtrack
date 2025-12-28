import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

sealed class InventoryDisplayItem {
  const InventoryDisplayItem();
}

class InventoryHeaderItem extends InventoryDisplayItem {
  final String storeName;
  final DateTime entryDate;
  const InventoryHeaderItem({required this.storeName, required this.entryDate});

  @override
  bool operator ==(Object other) =>
      other is InventoryHeaderItem &&
      storeName == other.storeName &&
      entryDate == other.entryDate;

  @override
  int get hashCode => Object.hash(storeName, entryDate);
}

class InventoryProductItem extends InventoryDisplayItem {
  final String itemId;
  const InventoryProductItem(this.itemId);

  @override
  bool operator ==(Object other) =>
      other is InventoryProductItem && itemId == other.itemId;

  @override
  int get hashCode => itemId.hashCode;
}

class InventorySpacerItem extends InventoryDisplayItem {
  const InventorySpacerItem();

  @override
  bool operator ==(Object other) => other is InventorySpacerItem;

  @override
  int get hashCode => 0;
}

@riverpod
AsyncValue<List<InventoryDisplayItem>> inventoryDisplayList(Ref ref) {
  final showOnlyAvailable = ref.watch(inventoryFilterProvider);

  final fridgeState = ref.watch(fridgeItemsProvider);

  return fridgeState.whenData((items) {
    final structure = items.map(
      (item) => (
        id: item.id,
        receiptId: item.receiptId ?? '',
        storeName: item.storeName,
        entryDate: item.entryDate,
        hasQuantity: item.quantity > 0,
      ),
    );

    if (showOnlyAvailable) {
      return structure
          .where((s) => s.hasQuantity)
          .map<InventoryDisplayItem>((s) => InventoryProductItem(s.id))
          .toList();
    }

    final groupedMap =
        <
          String,
          List<
            ({
              String id,
              String receiptId,
              String storeName,
              DateTime entryDate,
              bool hasQuantity,
            })
          >
        >{};
    for (final item in structure) {
      groupedMap.putIfAbsent(item.receiptId, () => []).add(item);
    }

    final displayList = <InventoryDisplayItem>[];
    for (final group in groupedMap.entries) {
      if (group.value.isEmpty) continue;

      final first = group.value.first;
      displayList.add(
        InventoryHeaderItem(
          storeName: first.storeName,
          entryDate: first.entryDate,
        ),
      );
      displayList.addAll(group.value.map((s) => InventoryProductItem(s.id)));
      displayList.add(const InventorySpacerItem());
    }

    return displayList;
  });
}
