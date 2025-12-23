import 'dart:async';

import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/inventory_providers.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_controller.g.dart';

@riverpod
class InventoryController extends _$InventoryController {
  @override
  FutureOr<void> build() {}

  Future<void> deleteAllItems() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(localStorageServiceProvider).deleteAllItems();
      ref.invalidate(fridgeItemsProvider);
    });
  }
}

sealed class InventoryDisplayItem {}

class InventoryHeaderItem extends InventoryDisplayItem {
  final FridgeItem item;
  InventoryHeaderItem(this.item);
}

class InventoryProductItem extends InventoryDisplayItem {
  final FridgeItem item;
  InventoryProductItem(this.item);
}

class InventorySpacerItem extends InventoryDisplayItem {
  InventorySpacerItem();
}

@riverpod
Future<List<InventoryDisplayItem>> inventoryDisplayList(Ref ref) async {
  final showOnlyAvailable = ref.watch(inventoryFilterProvider);

  if (showOnlyAvailable) {
    final items = await ref.watch(availableFridgeItemsProvider.future);
    return items.map((item) => InventoryProductItem(item)).toList();
  }

  final groupedItems = await ref.watch(groupedFridgeItemsProvider.future);
  final displayList = <InventoryDisplayItem>[];

  for (final group in groupedItems) {
    final groupItems = group.value;
    if (groupItems.isEmpty) continue;

    displayList.add(InventoryHeaderItem(groupItems.first));
    displayList.addAll(groupItems.map((item) => InventoryProductItem(item)));
    displayList.add(InventorySpacerItem());
  }

  return displayList;
}
