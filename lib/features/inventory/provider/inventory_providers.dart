import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';

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
    ref.invalidateSelf();
  }

  Future<void> updateItem(FridgeItem item) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.updateItem(item);
    ref.invalidateSelf();
  }

  Future<void> updateQuantity(FridgeItem item, int delta) async {
    final previousList = state.asData?.value;
    if (previousList == null) return;

    var newQuantity = item.quantity + delta;
    var newIsConsumed = item.isConsumed;
    var newConsumptionEvents = List<DateTime>.from(item.consumptionEvents);

    if (delta < 0) {
      newConsumptionEvents.add(DateTime.now());
    } else if (delta > 0 && newConsumptionEvents.isNotEmpty) {
      // coverage:ignore-line
      newConsumptionEvents.removeLast(); // coverage:ignore-line
    }

    if (newQuantity <= 0) {
      newQuantity = 0;
      newIsConsumed = true;
    } else if (newIsConsumed) {
      newIsConsumed = false;
    }

    final updatedList = [
      for (final i in previousList)
        if (i.id == item.id)
          i.copyWith(
            quantity: newQuantity,
            isConsumed: newIsConsumed,
            consumptionEvents: newConsumptionEvents,
          )
        else
          i, // coverage:ignore-line
    ];
    state = AsyncValue.data(updatedList);

    try {
      final repository = ref.read(fridgeRepositoryProvider);
      await repository.updateQuantity(item, delta);
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
}

@riverpod
class InventoryFilter extends _$InventoryFilter {
  @override
  InventoryFilterType build() => InventoryFilterType.all;

  void setFilter(InventoryFilterType type) => state = type;
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

final _loadingItem = FridgeItem(
  id: 'loading',
  name: AppLocalizations.loading,
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
