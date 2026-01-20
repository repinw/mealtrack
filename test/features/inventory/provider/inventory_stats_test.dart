import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/domain/inventory_stats.dart';

class MockFridgeItems extends FridgeItems {
  final List<FridgeItem> items;
  MockFridgeItems(this.items);

  @override
  Stream<List<FridgeItem>> build() => Stream.value(items);
}

void main() {
  group('InventoryStats Provider Tests', () {
    test('Happy Path: Correctly aggregates items', () async {
      final items = [
        FridgeItem(
          id: '1',
          name: 'Item 1',
          quantity: 2,
          unitPrice: 1.50,
          storeName: 'Store',
          entryDate: DateTime.now(),
          receiptId: 'R1',
        ),
        FridgeItem(
          id: '2',
          name: 'Item 2',
          quantity: 1,
          unitPrice: 2.00,
          storeName: 'Store',
          entryDate: DateTime.now(),
          receiptId: 'R2',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          fridgeItemsProvider.overrideWith(() => MockFridgeItems(items)),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(fridgeItemsProvider.future);
      container.listen(inventoryStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(inventoryStatsProvider);

      expect(stats.totalValue, 5.00);
      expect(stats.articleCount, 3);
      expect(stats.scanCount, 2);
    });

    test('Edge Case: Quantity 0 items are ignored', () async {
      final items = [
        FridgeItem(
          id: '1',
          name: 'Active Item',
          quantity: 2,
          unitPrice: 10.0,
          storeName: 'Store',
          entryDate: DateTime.now(),
        ),
        FridgeItem(
          id: '2',
          name: 'Zero Quantity Item',
          quantity: 0,
          unitPrice: 100.0,
          storeName: 'Store',
          entryDate: DateTime.now(),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          fridgeItemsProvider.overrideWith(() => MockFridgeItems(items)),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(fridgeItemsProvider.future);
      container.listen(inventoryStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(inventoryStatsProvider);

      expect(stats.totalValue, 20.0);
      expect(stats.articleCount, 2);
      expect(
        stats.scanCount,
        0,
      ); // scanCount is based on receiptId (null in this case)
    });

    test('Edge Case: scanCount correctly counts unique receiptIds', () async {
      final items = [
        FridgeItem(
          id: '1',
          name: 'I1',
          quantity: 1,
          unitPrice: 1.0,
          storeName: 'S',
          entryDate: DateTime.now(),
          receiptId: 'R1',
        ),
        FridgeItem(
          id: '2',
          name: 'I2',
          quantity: 1,
          unitPrice: 1.0,
          storeName: 'S',
          entryDate: DateTime.now(),
          receiptId: 'R1',
        ),
        FridgeItem(
          id: '3',
          name: 'I3',
          quantity: 1,
          unitPrice: 1.0,
          storeName: 'S',
          entryDate: DateTime.now(),
          receiptId: 'R2',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          fridgeItemsProvider.overrideWith(() => MockFridgeItems(items)),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(fridgeItemsProvider.future);
      container.listen(inventoryStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(inventoryStatsProvider);

      expect(stats.scanCount, 2);
    });

    test('Edge Case: Empty list returns empty stats', () async {
      final container = ProviderContainer(
        overrides: [
          fridgeItemsProvider.overrideWith(() => MockFridgeItems([])),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(fridgeItemsProvider.future);
      container.listen(inventoryStatsProvider, (_, _) {});

      await statsFuture;

      final stats = container.read(inventoryStatsProvider);

      expect(stats, InventoryStats.empty);
    });
  });
}
