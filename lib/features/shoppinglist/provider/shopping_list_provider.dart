import 'package:mealtrack/features/shoppinglist/domain/shopping_list_stats.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';

part 'shopping_list_provider.g.dart';

@riverpod
class ShoppingList extends _$ShoppingList {
  @override
  Stream<List<ShoppingListItem>> build() {
    final repository = ref.watch(shoppingListRepositoryProvider);
    return repository.watchItems();
  }

  Future<void> addItem(
    String name, {
    String? brand,
    int quantity = 1,
    double? unitPrice,
  }) async {
    final repository = ref.read(shoppingListRepositoryProvider);
    final items = await repository.watchItems().first;

    try {
      final existingItem = items.firstWhere(
        (i) => i.name == name && i.brand == brand,
      );
      final updated = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        unitPrice: unitPrice ?? existingItem.unitPrice,
      );
      await repository.updateItem(updated);
    } catch (_) {
      final item = ShoppingListItem.create(
        name: name,
        brand: brand,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      await repository.addItem(item);
    }
  }

  Future<void> deleteItem(String id) async {
    final repository = ref.read(shoppingListRepositoryProvider);
    await repository.deleteItem(id);
  }

  Future<void> toggleItem(String id) async {
    final repository = ref.read(shoppingListRepositoryProvider);
    final items = await repository.watchItems().first;
    final item = items.firstWhere((i) => i.id == id);
    final updated = item.copyWith(isChecked: !item.isChecked);
    await repository.updateItem(updated);
  }

  Future<void> updateQuantity(String id, int delta) async {
    final repository = ref.read(shoppingListRepositoryProvider);
    final items = await repository.watchItems().first;
    final item = items.firstWhere((i) => i.id == id);
    final newQuantity = item.quantity + delta;
    if (newQuantity > 0) {
      final updated = item.copyWith(quantity: newQuantity);
      await repository.updateItem(updated);
    }
  }

  Future<void> clearList() async {
    final repository = ref.read(shoppingListRepositoryProvider);
    await repository.clearList();
  }
}

@riverpod
ShoppingListStats shoppingListStats(Ref ref) {
  final itemsAsync = ref.watch(shoppingListProvider);

  if (!itemsAsync.hasValue) {
    return ShoppingListStats.empty;
  }

  final items = itemsAsync.value!;
  final activeItems = items.where((i) => i.quantity > 0).toList();

  final totalValue = activeItems.fold(
    0.0,
    (sum, i) => sum + (i.unitPrice ?? 0.0) * i.quantity,
  );

  final scanCount = activeItems
      .map((e) => e.id)
      .where((e) => e.isNotEmpty)
      .toSet()
      .length;

  final articleCount = activeItems.fold(0, (sum, i) => sum + i.quantity);

  return ShoppingListStats(
    totalValue: totalValue,
    scanCount: scanCount,
    articleCount: articleCount,
  );
}
