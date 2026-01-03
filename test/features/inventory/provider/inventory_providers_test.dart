import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorageService;
  late ProviderContainer container;

  setUp(() {
    mockStorageService = MockLocalStorageService();
    container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(mockStorageService),
      ],
    );
    registerFallbackValue(<FridgeItem>[]);
  });

  tearDown(() {
    container.dispose();
  });

  group('FridgeItems Notifier', () {
    final fixedDate = DateTime(2023, 1, 1);
    final item1 = FridgeItem.create(
      name: 'Item 1',
      storeName: 'Store A',
      quantity: 1,
      now: () => fixedDate,
    );
    final item2 = FridgeItem.create(
      name: 'Item 2',
      storeName: 'Store B',
      quantity: 2,
      now: () => fixedDate,
    );

    test('build loads items from storage', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);

      final items = await container.read(fridgeItemsProvider.future);

      expect(items, [item1, item2]);
      verify(() => mockStorageService.loadItems()).called(1);
    });

    test('reload re-fetches items from storage', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1]);

      await container.read(fridgeItemsProvider.future);

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);

      await container.read(fridgeItemsProvider.notifier).reload();

      final items = await container.read(fridgeItemsProvider.future);
      expect(items, [item1, item2]);
      verify(() => mockStorageService.loadItems()).called(2);
    });

    test('addItems appends items to existing list and saves', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item2]);
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.notifier).addItems([item1]);

      verify(() => mockStorageService.loadItems()).called(2);
      verify(() => mockStorageService.saveItems([item2, item1])).called(1);
    });

    test('updateItem updates specific item and saves list', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.future);

      final updatedItem1 = item1.copyWith(quantity: 5);
      await container
          .read(fridgeItemsProvider.notifier)
          .updateItem(updatedItem1);

      verify(
        () => mockStorageService.saveItems([updatedItem1, item2]),
      ).called(1);
    });

    test('updateItem does nothing if item not found', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1]);

      await container.read(fridgeItemsProvider.future);

      final newItem = FridgeItem.create(name: 'New', storeName: 'Store');

      await container.read(fridgeItemsProvider.notifier).updateItem(newItem);

      verifyNever(() => mockStorageService.saveItems(any()));
    });

    test(
      'deleteItemsByReceipt deletes all items with matching receiptId',
      () async {
        final itemWithReceipt1 = FridgeItem.create(
          name: 'Item A',
          storeName: 'Store',
          quantity: 1,
          now: () => fixedDate,
          receiptId: 'receipt-1',
        );
        final itemWithReceipt2 = FridgeItem.create(
          name: 'Item B',
          storeName: 'Store',
          quantity: 1,
          now: () => fixedDate,
          receiptId: 'receipt-1',
        );
        final itemWithDifferentReceipt = FridgeItem.create(
          name: 'Item C',
          storeName: 'Store',
          quantity: 1,
          now: () => fixedDate,
          receiptId: 'receipt-2',
        );

        when(() => mockStorageService.loadItems()).thenAnswer(
          (_) async => [
            itemWithReceipt1,
            itemWithReceipt2,
            itemWithDifferentReceipt,
          ],
        );
        when(
          () => mockStorageService.saveItems(any()),
        ).thenAnswer((_) async {});

        await container.read(fridgeItemsProvider.future);

        await container
            .read(fridgeItemsProvider.notifier)
            .deleteItemsByReceipt('receipt-1');

        verify(() => mockStorageService.saveItems(any())).called(2);
      },
    );
  });

  group('InventoryFilter', () {
    test('initial state is false', () {
      final filter = container.read(inventoryFilterProvider);
      expect(filter, InventoryFilterType.all);
    });

    test('toggle switches state', () {
      container
          .read(inventoryFilterProvider.notifier)
          .setFilter(InventoryFilterType.available);
      expect(
        container.read(inventoryFilterProvider),
        InventoryFilterType.available,
      );
      container
          .read(inventoryFilterProvider.notifier)
          .setFilter(InventoryFilterType.all);
      expect(container.read(inventoryFilterProvider), InventoryFilterType.all);
    });
  });

  group('availableFridgeItems', () {
    test('returns only items with quantity > 0', () async {
      final item1 = FridgeItem.create(
        name: 'A',
        storeName: 'S',
        quantity: 1,
        now: () => DateTime.now(),
      );
      final item2 = FridgeItem.create(
        name: 'B',
        storeName: 'S',
        quantity: 1,
        now: () => DateTime.now(),
      ).copyWith(quantity: 0);

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);

      final available = await container.read(
        availableFridgeItemsProvider.future,
      );
      expect(available.length, 1);
      expect(available.first.name, 'A');
    });
  });

  group('groupedFridgeItems', () {
    test('groups items by receiptId', () async {
      final item1 = FridgeItem.create(
        name: 'A',
        storeName: 'Store1',
        receiptId: 'R1',
      );
      final item2 = FridgeItem.create(
        name: 'B',
        storeName: 'Store1',
        receiptId: 'R1',
      );
      final item3 = FridgeItem.create(
        name: 'C',
        storeName: 'Store1',
        receiptId: 'R2',
      );
      final item4 = FridgeItem.create(
        name: 'D',
        storeName: 'Store2',
        // receiptId is null
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2, item3, item4]);

      final grouped = await container.read(groupedFridgeItemsProvider.future);

      expect(grouped.length, 3);
      expect(grouped.firstWhere((e) => e.key == 'R1').value.length, 2);
      expect(grouped.firstWhere((e) => e.key == 'R2').value.length, 1);
      expect(grouped.firstWhere((e) => e.key == '').value.length, 1);
    });
  });

  group('fridgeItemProvider', () {
    test('returns correct item by ID when data is loaded', () async {
      final item1 = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );
      final item2 = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 3,
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);

      await container.read(fridgeItemsProvider.future);

      final result = container.read(fridgeItemProvider(item1.id));
      expect(result.name, 'Apple');
      expect(result.quantity, 5);
    });

    test('returns loading item when state is not yet loaded', () {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      final result = container.read(fridgeItemProvider('any-id'));

      expect(result.id, 'loading');
      expect(result.name, 'Lädt...');
    });

    test('returns loading item when item ID is not found', () async {
      final item1 = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1]);

      await container.read(fridgeItemsProvider.future);

      final result = container.read(fridgeItemProvider('non-existent-id'));

      expect(result.id, 'loading');
      expect(result.name, 'Lädt...');
    });
  });

  group('updateQuantity optimistic update', () {
    test(
      'updates state immediately before async operation completes',
      () async {
        final item = FridgeItem.create(
          name: 'Apple',
          storeName: 'Store',
          quantity: 5,
        );

        when(
          () => mockStorageService.loadItems(),
        ).thenAnswer((_) async => [item]);
        when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
        });

        await container.read(fridgeItemsProvider.future);

        container.read(fridgeItemsProvider.notifier).updateQuantity(item, -1);

        final stateAfterUpdate = container.read(fridgeItemsProvider);
        expect(stateAfterUpdate.asData?.value.first.quantity, 4);
      },
    );

    test('does nothing when state is still loading', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      when(() => mockStorageService.loadItems()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return [item];
      });

      container.read(fridgeItemsProvider);

      container.read(fridgeItemsProvider.notifier).updateQuantity(item, -1);

      final state = container.read(fridgeItemsProvider);
      expect(state.isLoading, true);
    });

    test('rolls back state when repository throws exception', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item]);
      when(
        () => mockStorageService.saveItems(any()),
      ).thenThrow(Exception('Network error'));

      await container.read(fridgeItemsProvider.future);

      final initialState = container.read(fridgeItemsProvider);
      expect(initialState.asData?.value.first.quantity, 5);

      try {
        await container
            .read(fridgeItemsProvider.notifier)
            .updateQuantity(item, -1);
      } catch (_) {
        // Expected to throw
      }

      final stateAfterRollback = container.read(fridgeItemsProvider);
      expect(stateAfterRollback.asData?.value.first.quantity, 5);
    });

    test('rethrows exception after rollback', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item]);
      when(
        () => mockStorageService.saveItems(any()),
      ).thenThrow(Exception('Network error'));

      await container.read(fridgeItemsProvider.future);

      expect(
        () => container
            .read(fridgeItemsProvider.notifier)
            .updateQuantity(item, -1),
        throwsException,
      );
    });
  });

  group('inventoryStatsProvider', () {
    test('happy path: computes totalValue and articleCount correctly', () async {
      final item1 = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 2,
        unitPrice: 1.50,
        receiptId: 'receipt-1',
      );
      final item2 = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 3,
        unitPrice: 0.80,
        receiptId: 'receipt-2',
      );
      final item3 = FridgeItem.create(
        name: 'Milk',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 2.00,
        receiptId: 'receipt-3',
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2, item3]);

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      // totalValue = (2 * 1.50) + (3 * 0.80) + (1 * 2.00) = 3.00 + 2.40 + 2.00 = 7.40
      expect(stats.totalValue, closeTo(7.40, 0.001));
      // articleCount = 2 + 3 + 1 = 6
      expect(stats.articleCount, 6);
      // scanCount = 3 unique receiptIds
      expect(stats.scanCount, 3);
      expect(stats.scanCount, 3);
    });

    test('considers discounts in totalValue calculation', () async {
      final item1 = FridgeItem.create(
        name: 'Item 1',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 10.0,
        discounts: {'Discount': -2.0},
      );
      final item2 = FridgeItem.create(
        name: 'Item 2',
        storeName: 'Store',
        quantity: 2,
        unitPrice: 5.0,
        discounts: {'Discount': -1.0},
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      // Item 1: (10.0 - 2.0) * 1 = 8.0
      // Item 2: (5.0 - 1.0) * 2 = 8.0
      // Total: 16.0
      expect(stats.totalValue, closeTo(16.0, 0.001));
    });

    test('scanCount is 1 when multiple items have same receiptId', () async {
      final item1 = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.00,
        receiptId: 'same-receipt',
      );
      final item2 = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 2.00,
        receiptId: 'same-receipt',
      );
      final item3 = FridgeItem.create(
        name: 'Milk',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 3.00,
        receiptId: 'same-receipt',
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2, item3]);

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.scanCount, 1);
      expect(stats.articleCount, 3);
      expect(stats.totalValue, closeTo(6.00, 0.001));
    });

    test('returns empty stats for empty list', () async {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.totalValue, 0);
      expect(stats.scanCount, 0);
      expect(stats.articleCount, 0);
    });

    test('items with quantity 0 (consumed) are excluded from stats', () async {
      final activeItem = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 2,
        unitPrice: 1.50,
        receiptId: 'receipt-1',
      );
      final consumedItem = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 5.00,
        receiptId: 'receipt-2',
      ).copyWith(quantity: 0, isConsumed: true); // consumed via copyWith

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [activeItem, consumedItem]);

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      // Only active item counts: 2 * 1.50 = 3.00
      expect(stats.totalValue, closeTo(3.00, 0.001));
      // Only active item quantity counts
      expect(stats.articleCount, 2);
      // Only active item's receipt counts
      expect(stats.scanCount, 1);
    });

    test('returns empty stats when items are still loading', () {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return [];
      });

      // Don't await - items are still loading
      container.read(fridgeItemsProvider);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.totalValue, 0);
      expect(stats.scanCount, 0);
      expect(stats.articleCount, 0);
    });

    test('handles items with null or empty receiptId', () async {
      final itemWithReceipt = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.00,
        receiptId: 'receipt-1',
      );
      final itemWithEmptyReceipt = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 2.00,
        receiptId: '',
      );
      final itemWithNullReceipt = FridgeItem.create(
        name: 'Milk',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 3.00,
        // receiptId is null
      );

      when(() => mockStorageService.loadItems()).thenAnswer(
        (_) async => [
          itemWithReceipt,
          itemWithEmptyReceipt,
          itemWithNullReceipt,
        ],
      );

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      // Only 1 valid receipt counts
      expect(stats.scanCount, 1);
      // All items count for articleCount and totalValue
      expect(stats.articleCount, 3);
      expect(stats.totalValue, closeTo(6.00, 0.001));
    });
  });
}
