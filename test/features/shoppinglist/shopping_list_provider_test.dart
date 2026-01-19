import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';

import 'package:rxdart/rxdart.dart';

class FakeShoppingListRepository implements ShoppingListRepository {
  final _itemsSubject = BehaviorSubject<List<ShoppingListItem>>.seeded([]);

  @override
  Future<void> addItem(ShoppingListItem item) async {
    final current = _itemsSubject.value;
    _itemsSubject.add([...current, item]);
  }

  @override
  Future<void> deleteItem(String id) async {
    final current = _itemsSubject.value;
    _itemsSubject.add(current.where((item) => item.id != id).toList());
  }

  @override
  Future<void> updateItem(ShoppingListItem item) async {
    final current = _itemsSubject.value;
    _itemsSubject.add(current.map((i) => i.id == item.id ? item : i).toList());
  }

  @override
  Future<void> clearList() async {
    _itemsSubject.add([]);
  }

  @override
  Stream<List<ShoppingListItem>> watchItems() => _itemsSubject.stream;
}

void main() {
  group('Shopping List Provider', () {
    test('initial state should be empty list', () async {
      final repository = FakeShoppingListRepository();
      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      // ignore: unused_local_variable
      final subscription = container.listen(shoppingListProvider, (_, _) {});

      // The initial state might be loading or data depending on stream behavior.
      // We mainly care that it eventually emits the empty list.
      await expectLater(
        container.read(shoppingListProvider.future),
        completion([]),
      );
    });

    test('addItem should add item to repository', () async {
      final repository = FakeShoppingListRepository();
      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      // We need to access the notifier to call methods
      final provider = container.read(shoppingListProvider.notifier);

      // Attempt to add an item
      // This will fail (compilation or runtime) until we implement addItem in the provider
      await provider.addItem('Milk');

      // Verify repository was updated
      final items = await repository.watchItems().first;
      expect(items.length, 1);
      expect(items.first.name, 'Milk');
    });

    test('deleteItem should remove item from repository', () async {
      final repository = FakeShoppingListRepository();
      final item = ShoppingListItem.create(name: 'Bread');
      await repository.addItem(item);

      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final provider = container.read(shoppingListProvider.notifier);
      await provider.deleteItem(item.id);

      final items = await repository.watchItems().first;
      expect(items, isEmpty);
    });

    test('toggleItem should update item status', () async {
      final repository = FakeShoppingListRepository();
      final item = ShoppingListItem.create(name: 'Bread');
      await repository.addItem(item);

      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final provider = container.read(shoppingListProvider.notifier);
      await provider.toggleItem(item.id);

      final items = await repository.watchItems().first;
      expect(items.first.isChecked, true);
    });

    test('updateQuantity should update item quantity', () async {
      final repository = FakeShoppingListRepository();
      final item = ShoppingListItem.create(name: 'Bread', quantity: 1);
      await repository.addItem(item);

      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final provider = container.read(shoppingListProvider.notifier);
      await provider.updateQuantity(item.id, 1); // Increase by 1

      final items = await repository.watchItems().first;
      expect(items.first.quantity, 2);

      await provider.updateQuantity(item.id, -1); // Decrease by 1
      final items2 = await repository.watchItems().first;
      expect(items2.first.quantity, 1);
    });

    test('clearList should remove all items', () async {
      final repository = FakeShoppingListRepository();
      await repository.addItem(ShoppingListItem.create(name: 'A'));
      await repository.addItem(ShoppingListItem.create(name: 'B'));

      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final provider = container.read(shoppingListProvider.notifier);
      await provider.clearList();

      final items = await repository.watchItems().first;
      expect(items, isEmpty);
    });
  });
}
