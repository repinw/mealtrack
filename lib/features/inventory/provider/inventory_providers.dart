import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';

part 'inventory_providers.g.dart';

@riverpod
class FridgeItems extends _$FridgeItems {
  Timer? _saveTimer;
  final Map<String, int> _pendingDeltas = {};

  @override
  Future<List<FridgeItem>> build() async {
    final repository = ref.watch(fridgeRepositoryProvider);

    ref.onDispose(() {
      _saveTimer?.cancel();
    });

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
    ref.invalidateSelf();
  }

  Future<void> updateItem(FridgeItem item) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.updateItem(item);
    ref.invalidateSelf();
  }

  void updateQuantity(FridgeItem item, int delta) {
    _pendingDeltas[item.id] = (_pendingDeltas[item.id] ?? 0) + delta;

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1000), _applyPendingDeltas);
  }

  Future<void> _applyPendingDeltas() async {
    if (_pendingDeltas.isEmpty) return;

    final deltasToApply = Map<String, int>.from(_pendingDeltas);
    _pendingDeltas.clear();

    state = state.whenData((items) {
      final updatedList = [...items];

      for (final entry in deltasToApply.entries) {
        final index = items.indexWhere((i) => i.id == entry.key);
        if (index == -1) continue;

        final currentItem = items[index];
        var quantity = currentItem.quantity + entry.value;
        var isConsumed = currentItem.isConsumed;
        DateTime? consumptionDate = currentItem.consumptionDate;

        if (quantity <= 0) {
          quantity = 0;
          isConsumed = true;
        } else if (isConsumed) {
          isConsumed = false;
          consumptionDate = null;
        }

        updatedList[index] = currentItem.copyWith(
          quantity: quantity,
          isConsumed: isConsumed,
          consumptionDate: consumptionDate,
          clearConsumptionDate: consumptionDate == null,
        );
      }

      return updatedList;
    });

    try {
      final repository = ref.read(fridgeRepositoryProvider);
      await repository.saveItems(state.asData?.value ?? []);
    } catch (e) {
      debugPrint('Error saving quantity update: $e');
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

final fridgeItemProvider = Provider.autoDispose.family<FridgeItem, String>((
  ref,
  id,
) {
  return ref.watch(
    fridgeItemsProvider.select(
      (state) =>
          state.asData?.value.firstWhere(
            (element) => element.id == id,
            orElse: () => FridgeItem(
              id: id,
              name: 'Loading...',
              quantity: 0,
              storeName: '',
              entryDate: DateTime.now(),
            ),
          ) ??
          FridgeItem(
            id: id,
            name: 'Loading...',
            quantity: 0,
            storeName: '',
            entryDate: DateTime.now(),
          ),
    ),
  );
});
