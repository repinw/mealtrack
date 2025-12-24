import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';

part 'inventory_providers.g.dart';

@riverpod
class FridgeItems extends _$FridgeItems {
  @override
  Future<List<FridgeItem>> build() async {
    final service = ref.watch(localStorageServiceProvider);
    return service.loadItems();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(localStorageServiceProvider);
      return service.loadItems();
    });
  }

  Future<void> addItems(List<FridgeItem> items) async {
    final service = ref.read(localStorageServiceProvider);
    final currentItems = await service.loadItems();
    await service.saveItems([...currentItems, ...items]);
    ref.invalidateSelf();
  }

  Future<void> updateItem(FridgeItem item) async {
    final service = ref.read(localStorageServiceProvider);
    final currentList = state.value ?? await service.loadItems();

    final index = currentList.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      final newList = List<FridgeItem>.from(currentList);
      newList[index] = item;
      await service.saveItems(newList);
      ref.invalidateSelf();
    }
  }

  Future<void> updateQuantity(FridgeItem item, int delta) async {
    var quantity = item.quantity + delta;
    var isConsumed = item.isConsumed;
    var consumptionDate = item.consumptionDate;

    if (quantity <= 0) {
      quantity = 0;
      isConsumed = true;
    } else if (isConsumed) {
      isConsumed = false;
      consumptionDate = null;
    }

    await updateItem(
      item.copyWith(
        quantity: quantity,
        isConsumed: isConsumed,
        consumptionDate: consumptionDate,
      ),
    );
  }
}

@riverpod
class InventoryFilter extends _$InventoryFilter {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
Future<List<FridgeItem>> availableFridgeItems(Ref ref) async {
  final items = await ref.watch(fridgeItemsProvider.future);
  return items.where((item) => item.quantity > 0).toList();
}

@riverpod
Future<List<MapEntry<String, List<FridgeItem>>>> groupedFridgeItems(
  Ref ref,
) async {
  final items = await ref.watch(fridgeItemsProvider.future);

  final groupedMap = <String, List<FridgeItem>>{};

  for (final item in items) {
    final key = '${item.storeName}_${item.entryDate.minute}';

    if (!groupedMap.containsKey(key)) {
      groupedMap[key] = [];
    }
    groupedMap[key]!.add(item);
  }

  return groupedMap.entries.toList();
}
