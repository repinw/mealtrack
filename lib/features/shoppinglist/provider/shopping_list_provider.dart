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

  Future<void> addItem(String name, {String? brand, int quantity = 1}) async {
    final repository = ref.read(shoppingListRepositoryProvider);
    final item = ShoppingListItem.create(
      name: name,
      brand: brand,
      quantity: quantity,
    );
    await repository.addItem(item);
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
