import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/inventory_providers.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
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

    test('addItems saves items and invalidates state', () async {
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.notifier).addItems([item1]);

      verify(() => mockStorageService.saveItems([item1])).called(1);
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

    test('updateQuantity updates quantity and handles consumption', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1]);
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.future);

      await container
          .read(fridgeItemsProvider.notifier)
          .updateQuantity(item1, -1);

      final captured = verify(
        () => mockStorageService.saveItems(captureAny()),
      ).captured;
      final savedList = captured.first as List<FridgeItem>;
      expect(savedList.first.quantity, 0);
      expect(savedList.first.isConsumed, true);
    });
  });

  group('InventoryFilter', () {
    test('initial state is false', () {
      final filter = container.read(inventoryFilterProvider);
      expect(filter, false);
    });

    test('toggle switches state', () {
      container.read(inventoryFilterProvider.notifier).toggle();
      expect(container.read(inventoryFilterProvider), true);
      container.read(inventoryFilterProvider.notifier).toggle();
      expect(container.read(inventoryFilterProvider), false);
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
    test('groups items by store and entry date', () async {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 1, 2);

      final item1 = FridgeItem.create(
        name: 'A',
        storeName: 'Store1',
        quantity: 1,
        now: () => date1,
      );
      final item2 = FridgeItem.create(
        name: 'B',
        storeName: 'Store1',
        quantity: 1,
        now: () => date1,
      );
      final item3 = FridgeItem.create(
        name: 'C',
        storeName: 'Store1',
        quantity: 1,
        now: () => date2,
      );
      final item4 = FridgeItem.create(
        name: 'D',
        storeName: 'Store2',
        quantity: 1,
        now: () => date1,
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2, item3, item4]);

      final grouped = await container.read(groupedFridgeItemsProvider.future);

      expect(grouped.length, 3);
      expect(grouped[0].value.length, 2); // Store1_date1
      expect(grouped[1].value.length, 1); // Store1_date2
      expect(grouped[2].value.length, 1); // Store2_date1
    });
  });
}
