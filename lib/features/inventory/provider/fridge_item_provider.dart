import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_item_controller.dart';
import 'package:mealtrack/features/inventory/data/fridge_item_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fridge_item_provider.g.dart';

@riverpod
FridgeItemRepository fridgeItemRepository(Ref ref) {
  return FridgeItemRepository();
}

@riverpod
Stream<List<FridgeItem>> fridgeItem(Ref ref) {
  final repository = ref.watch(fridgeItemRepositoryProvider);
  return repository.watchItems();
}

@riverpod
Future<List<FridgeItem>> availableFridgeItems(Ref ref) async {
  final items = await ref.watch(fridgeItemProvider.future);
  return items.where((item) => !item.isConsumed && item.quantity > 0).toList();
}

@riverpod
Future<List<MapEntry<String, List<FridgeItem>>>> groupedFridgeItems(
  Ref ref,
) async {
  final items = await ref.watch(fridgeItemProvider.future);
  final grouped = <String, List<FridgeItem>>{};
  for (var item in items) {
    final key =
        item.receiptId ??
        '${item.storeName}_${item.entryDate.year}-${item.entryDate.month}-${item.entryDate.day}';
    grouped.putIfAbsent(key, () => []).add(item);
  }

  final entries = grouped.entries.toList();
  entries.sort(
    (a, b) => b.value.first.entryDate.compareTo(a.value.first.entryDate),
  );
  return entries;
}

@riverpod
FridgeItemController fridgeItemController(Ref ref) {
  return FridgeItemController();
}

@riverpod
Future<List<FridgeItem>> reducedFridgeItem(Ref ref) async {
  final items = await ref.watch(fridgeItemProvider.future);
  return items.where((p) => p.isConsumed).toList();
}
