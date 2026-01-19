import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/data/in_memory_shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';

void main() {
  late InMemoryShoppingListRepository repository;

  setUp(() {
    repository = InMemoryShoppingListRepository();
  });

  group('InMemoryShoppingListRepository', () {
    test('starts with empty list', () {
      expect(repository.watchItems(), emits([]));
    });

    test('addItem adds item to the list', () async {
      final item = ShoppingListItem.create(name: 'Milk');
      await repository.addItem(item);
      expect(repository.watchItems(), emits([item]));
    });

    test('updateItem updates existing item', () async {
      final item = ShoppingListItem.create(name: 'Milk');
      await repository.addItem(item);

      final updatedItem = item.copyWith(isChecked: true);
      await repository.updateItem(updatedItem);

      expect(repository.watchItems(), emits([updatedItem]));
    });

    test('deleteItem removes item from the list', () async {
      final item = ShoppingListItem.create(name: 'Milk');
      await repository.addItem(item);

      await repository.deleteItem(item.id);

      expect(repository.watchItems(), emits([]));
    });

    test('deleteItem does nothing if id not found', () async {
      final item = ShoppingListItem.create(name: 'Milk');
      await repository.addItem(item);

      await repository.deleteItem('non-existent-id');

      expect(repository.watchItems(), emits([item]));
    });
  });
}
