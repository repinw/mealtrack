import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';

part 'inventory_providers.g.dart';

@riverpod
class FridgeItems extends _$FridgeItems {
  @override
  Future<List<FridgeItem>> build() async {
    final repository = ref.watch(fridgeRepositoryProvider);
    return repository.getItems();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(fridgeRepositoryProvider);
      return repository.getItems();
    });
  }

  Future<void> addItems(List<FridgeItem> items) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.addItems(items);
    try {
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error invalidating FridgeItems provider: $e');
    }
  }

  Future<void> updateItem(FridgeItem item) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.updateItem(item);
    try {
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error invalidating FridgeItems provider: $e');
    }
  }

  Future<void> updateQuantity(FridgeItem item, int delta) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.updateQuantity(item, delta);
    try {
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error invalidating FridgeItems provider: $e');
    }
  }

  Future<void> deleteAll() async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.deleteAllItems();
    try {
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error invalidating FridgeItems provider: $e');
    }
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
    final key = item.receiptId ?? '';
    if (!groupedMap.containsKey(key)) {
      groupedMap[key] = [];
    }
    groupedMap[key]!.add(item);
  }

  return groupedMap.entries.toList();
}
