import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_stats.dart';

class MockShoppingList extends ShoppingList {
  final List<ShoppingListItem> items;
  MockShoppingList(this.items);

  @override
  Stream<List<ShoppingListItem>> build() => Stream.value(items);
}

void main() {
  group('ShoppingListStats Provider Tests', () {
    test('Happy Path: Correctly aggregates items', () async {
      final items = [
        const ShoppingListItem(
          id: '1',
          name: 'Item 1',
          quantity: 2,
          unitPrice: 1.50,
          isChecked: false,
        ),
        const ShoppingListItem(
          id: '2',
          name: 'Item 2',
          quantity: 1,
          unitPrice: 2.00,
          isChecked: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          shoppingListProvider.overrideWith(() => MockShoppingList(items)),
        ],
      );
      addTearDown(container.dispose);

      // Listen to keep provider alive and wait for data
      final statsFuture = container.read(shoppingListProvider.future);
      container.listen(shoppingListStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, 5.00);
      expect(stats.articleCount, 3);
      expect(stats.scanCount, 2);
    });

    test('Edge Case: Handles null unitPrice (defaults to 0.0)', () async {
      final items = [
        const ShoppingListItem(
          id: '1',
          name: 'Null Price Item',
          quantity: 5,
          unitPrice: null,
          isChecked: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          shoppingListProvider.overrideWith(() => MockShoppingList(items)),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(shoppingListProvider.future);
      container.listen(shoppingListStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, 0.0);
      expect(stats.articleCount, 5);
      expect(stats.scanCount, 1);
    });

    test('Edge Case: Quantity 0 items are ignored', () async {
      final items = [
        const ShoppingListItem(
          id: '1',
          name: 'Active Item',
          quantity: 2,
          unitPrice: 10.0,
          isChecked: false,
        ),
        const ShoppingListItem(
          id: '2',
          name: 'Zero Quantity Item',
          quantity: 0,
          unitPrice: 100.0,
          isChecked: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          shoppingListProvider.overrideWith(() => MockShoppingList(items)),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(shoppingListProvider.future);
      container.listen(shoppingListStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, 20.0);
      expect(stats.articleCount, 2);
      expect(stats.scanCount, 1);
    });

    test('Edge Case: Empty list returns empty stats', () async {
      final container = ProviderContainer(
        overrides: [
          shoppingListProvider.overrideWith(() => MockShoppingList([])),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(shoppingListProvider.future);
      container.listen(shoppingListStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, 0.0);
      expect(stats.articleCount, 0);
      expect(stats.scanCount, 0);
      expect(stats, ShoppingListStats.empty);
    });

    test('Edge Case: Negative prices/quantities (robustness)', () async {
      final items = [
        const ShoppingListItem(
          id: '1',
          name: 'Negative Price',
          quantity: 2,
          unitPrice: -5.0,
          isChecked: false,
        ),
        const ShoppingListItem(
          id: '2',
          name: 'Negative Quantity',
          quantity: -1,
          unitPrice: 10.0,
          isChecked: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          shoppingListProvider.overrideWith(() => MockShoppingList(items)),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(shoppingListProvider.future);
      container.listen(shoppingListStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(shoppingListStatsProvider);

      expect(stats.totalValue, -10.0);
      expect(stats.articleCount, 2);
      expect(stats.scanCount, 1);
    });

    test(
      'Edge Case: Mixed items (Normal, Null Price, Zero Quantity)',
      () async {
        final items = [
          const ShoppingListItem(
            id: '1',
            name: 'Normal Item',
            quantity: 2,
            unitPrice: 2.50,
            isChecked: false,
          ),
          const ShoppingListItem(
            id: '2',
            name: 'Null Price Item',
            quantity: 3,
            unitPrice: null,
            isChecked: false,
          ),
          const ShoppingListItem(
            id: '3',
            name: 'Zero Quantity Info',
            quantity: 0,
            unitPrice: 10.0,
            isChecked: false,
          ),
        ];

        final container = ProviderContainer(
          overrides: [
            shoppingListProvider.overrideWith(() => MockShoppingList(items)),
          ],
        );
        addTearDown(container.dispose);

        final statsFuture = container.read(shoppingListProvider.future);
        container.listen(shoppingListStatsProvider, (_, _) {});

        await statsFuture;

        final stats = container.read(shoppingListStatsProvider);

        // (2 * 2.50) + (3 * 0) + (0 * 10.0) = 5.0
        expect(stats.totalValue, 5.0);

        // 2 + 3 = 5 (Zero quantity items are not counted in article count)
        expect(stats.articleCount, 5);

        // Zero quantity items are excluded from scanCount
        expect(stats.scanCount, 2);
      },
    );
  });
}
