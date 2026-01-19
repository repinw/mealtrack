import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';

import 'package:mealtrack/features/shoppinglist/data/in_memory_shopping_list_repository.dart';

part 'shopping_list_repository.g.dart';

abstract class ShoppingListRepository {
  Stream<List<ShoppingListItem>> watchItems();
  Future<void> addItem(ShoppingListItem item);
  Future<void> updateItem(ShoppingListItem item);
  Future<void> deleteItem(String id);
  Future<void> clearList();
}

@riverpod
ShoppingListRepository shoppingListRepository(Ref ref) {
  return InMemoryShoppingListRepository();
}
