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
  Future<void> addOrMergeItem({
    required String name,
    required String? brand,
    String? category,
    required int quantity,
    required double? unitPrice,
  }) async {
    final current = _itemsSubject.value;
    final index = current.indexWhere((i) => i.name == name && i.brand == brand);
    if (index >= 0) {
      final existingItem = current[index];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        unitPrice: unitPrice ?? existingItem.unitPrice,
        category: category ?? existingItem.category,
      );
      final newItems = List<ShoppingListItem>.from(current);
      newItems[index] = updatedItem;
      _itemsSubject.add(newItems);
    } else {
      final newItem = ShoppingListItem.create(
        name: name,
        brand: brand,
        category: category,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      _itemsSubject.add([...current, newItem]);
    }
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

      final provider = container.read(shoppingListProvider.notifier);

      await provider.addItem('Milk');

      final items = await repository.watchItems().first;
      expect(items.length, 1);
      expect(items.first.name, 'Milk');
      expect(items.first.quantity, 1);
    });

    test('addItem should increment quantity if item already exists', () async {
      final repository = FakeShoppingListRepository();
      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final provider = container.read(shoppingListProvider.notifier);

      await provider.addItem('Milk');
      await provider.addItem('Milk');

      final items = await repository.watchItems().first;
      expect(items.length, 1);
      expect(items.first.name, 'Milk');
      expect(items.first.quantity, 2);
    });

    test('addItem should update unitPrice if item already exists', () async {
      final repository = FakeShoppingListRepository();
      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final provider = container.read(shoppingListProvider.notifier);

      await provider.addItem('Milk', unitPrice: 1.5);
      await provider.addItem('Milk', unitPrice: 2.0);

      final items = await repository.watchItems().first;
      expect(items.length, 1);
      expect(items.first.name, 'Milk');
      expect(items.first.quantity, 2);
      expect(items.first.unitPrice, 2.0);
    });

    test(
      'addItem should keep old unitPrice if new one is not provided (default null)',
      () async {
        final repository = FakeShoppingListRepository();
        final container = ProviderContainer(
          overrides: [
            shoppingListRepositoryProvider.overrideWith((ref) => repository),
          ],
        );
        addTearDown(container.dispose);

        final provider = container.read(shoppingListProvider.notifier);

        await provider.addItem('Milk', unitPrice: 1.5);
        await provider.addItem('Milk'); // No unitPrice provided

        final items = await repository.watchItems().first;
        expect(items.length, 1);
        expect(items.first.name, 'Milk');
        expect(items.first.quantity, 2);
        expect(items.first.unitPrice, 1.5);
      },
    );

    test(
      'addItem should keep old unitPrice if new one is explicitly null',
      () async {
        final repository = FakeShoppingListRepository();
        final container = ProviderContainer(
          overrides: [
            shoppingListRepositoryProvider.overrideWith((ref) => repository),
          ],
        );
        addTearDown(container.dispose);

        final provider = container.read(shoppingListProvider.notifier);

        await provider.addItem('Milk', unitPrice: 1.5);
        await provider.addItem('Milk', unitPrice: null);

        final items = await repository.watchItems().first;
        expect(items.length, 1);
        expect(items.first.name, 'Milk');
        expect(items.first.quantity, 2);
        expect(items.first.unitPrice, 1.5);
      },
    );

    test('addItem should match brand when checking for duplicates', () async {
      final repository = FakeShoppingListRepository();
      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final provider = container.read(shoppingListProvider.notifier);

      await provider.addItem('Milk', brand: 'Brand A');
      await provider.addItem('Milk', brand: 'Brand B');

      final items = await repository.watchItems().first;
      expect(items.length, 2);
      expect(items[0].brand, 'Brand A');
      expect(items[1].brand, 'Brand B');

      await provider.addItem('Milk', brand: 'Brand A');
      final items2 = await repository.watchItems().first;
      expect(items2.length, 2);
      // Depending on list order implementation, find by brand
      final brandA = items2.firstWhere((i) => i.brand == 'Brand A');
      expect(brandA.quantity, 2);
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

  group('Shopping List Stats', () {
    test(
      'Happy Path: should calculate stats correctly for active items',
      () async {
        final repository = FakeShoppingListRepository();
        // Total: (2.5 * 2) + (1.0 * 1) + (5.0 * 3) = 5.0 + 1.0 + 15.0 = 21.0
        // ArticleCount: 2 + 1 + 3 = 6
        // ScanCount: 3 unique IDs
        await repository.addItem(
          ShoppingListItem.create(name: 'A', unitPrice: 2.5, quantity: 2),
        );
        await repository.addItem(
          ShoppingListItem.create(name: 'B', unitPrice: 1.0, quantity: 1),
        );
        await repository.addItem(
          ShoppingListItem.create(name: 'C', unitPrice: 5.0, quantity: 3),
        );

        final container = ProviderContainer(
          overrides: [
            shoppingListRepositoryProvider.overrideWith((ref) => repository),
          ],
        );
        addTearDown(container.dispose);

        // Keep providers alive and wait for data
        container.listen(shoppingListProvider, (_, _) {});
        container.listen(shoppingListStatsProvider, (_, _) {});

        await container.read(shoppingListProvider.future);
        final stats = container.read(shoppingListStatsProvider);

        expect(stats.totalValue, 21.0);
        expect(stats.articleCount, 6);
        expect(stats.scanCount, 3);
      },
    );

    test('Edge Case: Null Price should be treated as 0.0', () async {
      final repository = FakeShoppingListRepository();
      await repository.addItem(
        ShoppingListItem.create(name: 'Free', unitPrice: null, quantity: 5),
      );

      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      container.listen(shoppingListProvider, (_, _) {});
      container.listen(shoppingListStatsProvider, (_, _) {});

      await container.read(shoppingListProvider.future);
      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, 0.0);
      expect(stats.articleCount, 5);
    });

    test('Edge Case: Zero Quantity should be ignored', () async {
      final repository = FakeShoppingListRepository();
      await repository.addItem(
        ShoppingListItem.create(name: 'Active', unitPrice: 10.0, quantity: 1),
      );
      await repository.addItem(
        ShoppingListItem.create(
          name: 'Inactive',
          unitPrice: 100.0,
          quantity: 0,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(shoppingListProvider, (_, _) {});
      container.listen(shoppingListStatsProvider, (_, _) {});

      await container.read(shoppingListProvider.future);
      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, 10.0);
      expect(stats.articleCount, 1);
      expect(stats.scanCount, 1);
    });

    test('Edge Case: Empty List should return empty stats', () async {
      final repository = FakeShoppingListRepository();
      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(shoppingListProvider, (_, _) {});
      container.listen(shoppingListStatsProvider, (_, _) {});

      await container.read(shoppingListProvider.future);
      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, 0.0);
      expect(stats.articleCount, 0);
      expect(stats.scanCount, 0);
    });

    test('Edge Case: Negative Prices should be handled robustly', () async {
      final repository = FakeShoppingListRepository();
      // Total: (10.0 * 2) + (-5.0 * 1) = 20.0 - 5.0 = 15.0
      await repository.addItem(
        ShoppingListItem.create(name: 'Plus', unitPrice: 10.0, quantity: 2),
      );
      await repository.addItem(
        ShoppingListItem.create(name: 'Minus', unitPrice: -5.0, quantity: 1),
      );

      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(shoppingListProvider, (_, _) {});
      container.listen(shoppingListStatsProvider, (_, _) {});

      await container.read(shoppingListProvider.future);
      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, 15.0);
      expect(stats.articleCount, 3);
    });

    test('addItem with new price updates totalValue in stats', () async {
      final repository = FakeShoppingListRepository();
      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      // Listen to both providers
      container.listen(shoppingListProvider, (_, _) {});
      container.listen(shoppingListStatsProvider, (_, _) {});

      final provider = container.read(shoppingListProvider.notifier);

      // 1. Add item with price 1.5
      await provider.addItem('Milk', unitPrice: 1.5, quantity: 2);
      await container.read(shoppingListProvider.future);

      expect(container.read(shoppingListStatsProvider).totalValue, 3.0);

      // 2. Add same item with price 2.0 (new price)
      await provider.addItem('Milk', unitPrice: 2.0, quantity: 1);
      await container.read(shoppingListProvider.future);

      // Total quantity: 2 + 1 = 3
      // New price should be 2.0
      // Expected total: 3 * 2.0 = 6.0
      expect(container.read(shoppingListStatsProvider).totalValue, 6.0);
    });
  });
}
