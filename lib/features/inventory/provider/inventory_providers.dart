import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final newQuantity = item.quantity + delta;
    final updatedList = [
      for (final i in previousList)
        if (i.id == item.id) i.copyWith(quantity: newQuantity) else i,
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

final _loadingItem = FridgeItem(
  id: 'loading',
  name: 'Loading...',
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
      } catch (_) {
        return _loadingItem;
      }
    }),
  );
});
