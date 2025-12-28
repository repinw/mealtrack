import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockFridgeRepository extends Mock implements FridgeRepository {}

void main() {
  late MockFridgeRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockFridgeRepository();
    container = ProviderContainer(
      overrides: [fridgeRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('InventoryViewModel', () {
    test('initial state is AsyncData(null)', () {
      final state = container.read(inventoryViewModelProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('deleteAllItems calls repository and invalidates providers', () async {
      final initialItem = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Test Store',
        quantity: 1,
        now: () => DateTime.now(),
      );
      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [initialItem]);

      await container.read(fridgeItemsProvider.future);

      when(() => mockRepository.deleteAllItems()).thenAnswer((_) async {});
      when(() => mockRepository.getItems()).thenAnswer((_) async => []);

      await container
          .read(inventoryViewModelProvider.notifier)
          .deleteAllItems();

      verify(() => mockRepository.deleteAllItems()).called(1);

      final newItems = await container.read(fridgeItemsProvider.future);
      expect(newItems, isEmpty);
    });

    test('deleteItem calls repository and updates state correctly', () async {
      final item1 = FridgeItem.create(
        name: 'Item 1',
        storeName: 'Store',
        quantity: 2,
        unitPrice: 10.0,
      );
      final item2 = FridgeItem.create(
        name: 'Item 2',
        storeName: 'Store',
        quantity: 3,
        unitPrice: 5.0,
      );

      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2]);

      await container.read(fridgeItemsProvider.future);

      when(() => mockRepository.deleteItem(item1.id)).thenAnswer((_) async {});
      when(() => mockRepository.getItems()).thenAnswer((_) async => [item2]);

      await container
          .read(inventoryViewModelProvider.notifier)
          .deleteItem(item1.id);

      verify(() => mockRepository.deleteItem(item1.id)).called(1);

      final currentItems = await container.read(fridgeItemsProvider.future);
      expect(currentItems, hasLength(1));
      expect(currentItems.first.id, item2.id);
    });
  });

  group('inventoryDisplayListProvider', () {
    final fixedDate = DateTime(2023, 1, 1, 12, 0, 0);
    final sharedReceiptId = 'receipt-123';
    final item1 = FridgeItem.create(
      name: 'Apple',
      storeName: 'Store A',
      quantity: 5,
      now: () => fixedDate,
    ).copyWith(receiptId: sharedReceiptId);
    final item2 = FridgeItem.create(
      name: 'Banana',
      storeName: 'Store A',
      quantity: 1,
      now: () => fixedDate,
    ).copyWith(quantity: 0, isConsumed: true, receiptId: sharedReceiptId);
    final item3 = FridgeItem.create(
      name: 'Carrot',
      storeName: 'Store B',
      quantity: 2,
      now: () => fixedDate,
    ).copyWith(receiptId: 'receipt-456');

    test(
      'returns grouped items including consumed ones when filter is disabled',
      () async {
        when(
          () => mockRepository.getItems(),
        ).thenAnswer((_) async => [item1, item2, item3]);

        // Wait for fridge items to load first
        await container.read(fridgeItemsProvider.future);

        // inventoryDisplayListProvider returns AsyncValue synchronously
        final displayListAsync = container.read(inventoryDisplayListProvider);
        final displayList = displayListAsync.value!;

        expect(displayList.length, 7);

        expect(displayList[0], isA<InventoryHeaderItem>());
        expect(
          (displayList[0] as InventoryHeaderItem).item.storeName,
          'Store A',
        );
        expect(displayList[1], isA<InventoryProductItem>());
        expect((displayList[1] as InventoryProductItem).itemId, item1.id);
        expect(displayList[2], isA<InventoryProductItem>());
        expect((displayList[2] as InventoryProductItem).itemId, item2.id);
        expect(displayList[3], isA<InventorySpacerItem>());

        expect(displayList[4], isA<InventoryHeaderItem>());
        expect(
          (displayList[4] as InventoryHeaderItem).item.storeName,
          'Store B',
        );
        expect(displayList[5], isA<InventoryProductItem>());
        expect((displayList[5] as InventoryProductItem).itemId, item3.id);
        expect(displayList[6], isA<InventorySpacerItem>());
      },
    );

    test('returns only available items when filter is enabled', () async {
      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2, item3]);

      container.read(inventoryFilterProvider.notifier).toggle();

      // Wait for fridge items to load first
      await container.read(fridgeItemsProvider.future);

      final displayListAsync = container.read(inventoryDisplayListProvider);
      final displayList = displayListAsync.value!;

      expect(displayList.length, 2);
      expect(displayList[0], isA<InventoryProductItem>());
      expect((displayList[0] as InventoryProductItem).itemId, item1.id);
      expect(displayList[1], isA<InventoryProductItem>());
      expect((displayList[1] as InventoryProductItem).itemId, item3.id);
    });

    test('returns empty list when no items exist', () async {
      when(() => mockRepository.getItems()).thenAnswer((_) async => []);

      // Wait for fridge items to load first
      await container.read(fridgeItemsProvider.future);

      final displayListAsync = container.read(inventoryDisplayListProvider);
      final displayList = displayListAsync.value!;

      expect(displayList, isEmpty);
    });
  });
}
