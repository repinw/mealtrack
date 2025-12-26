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
      // 1. Initial state: items exist
      final initialItem = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Test Store',
        quantity: 1,
        now: () => DateTime.now(),
      );
      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [initialItem]);

      // Ensure provider is initialized
      await container.read(fridgeItemsProvider.future);

      // 2. Mock deletion and subsequent empty fetch
      when(() => mockRepository.deleteAllItems()).thenAnswer((_) async {});
      when(() => mockRepository.getItems()).thenAnswer((_) async => []);

      // 3. Perform deletion
      await container
          .read(inventoryViewModelProvider.notifier)
          .deleteAllItems();

      // 4. Verify repository call and provider update
      verify(() => mockRepository.deleteAllItems()).called(1);

      // The provider should now return empty list
      final newItems = await container.read(fridgeItemsProvider.future);
      expect(newItems, isEmpty);
    });

    test('deleteAllItems propagates error when repository fails', () async {
      final exception = Exception('Delete failed');
      when(() => mockRepository.deleteAllItems()).thenThrow(exception);

      expect(
        () async => await container
            .read(inventoryViewModelProvider.notifier)
            .deleteAllItems(),
        throwsA(isA<Exception>()),
      );
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

        final displayList = await container.read(
          inventoryDisplayListProvider.future,
        );

        expect(displayList.length, 7);

        expect(displayList[0], isA<InventoryHeaderItem>());
        expect(
          (displayList[0] as InventoryHeaderItem).item.storeName,
          'Store A',
        );
        expect(displayList[1], isA<InventoryProductItem>());
        expect((displayList[1] as InventoryProductItem).item.name, 'Apple');
        expect(displayList[2], isA<InventoryProductItem>());
        expect((displayList[2] as InventoryProductItem).item.name, 'Banana');
        expect(displayList[3], isA<InventorySpacerItem>());

        expect(displayList[4], isA<InventoryHeaderItem>());
        expect(
          (displayList[4] as InventoryHeaderItem).item.storeName,
          'Store B',
        );
        expect(displayList[5], isA<InventoryProductItem>());
        expect((displayList[5] as InventoryProductItem).item.name, 'Carrot');
        expect(displayList[6], isA<InventorySpacerItem>());
      },
    );

    test('returns only available items when filter is enabled', () async {
      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2, item3]);

      container.read(inventoryFilterProvider.notifier).toggle();

      final displayList = await container.read(
        inventoryDisplayListProvider.future,
      );

      expect(displayList.length, 2);
      expect(displayList[0], isA<InventoryProductItem>());
      expect((displayList[0] as InventoryProductItem).item.name, 'Apple');
      expect(displayList[1], isA<InventoryProductItem>());
      expect((displayList[1] as InventoryProductItem).item.name, 'Carrot');
    });

    test('returns empty list when no items exist', () async {
      when(() => mockRepository.getItems()).thenAnswer((_) async => []);

      final displayList = await container.read(
        inventoryDisplayListProvider.future,
      );

      expect(displayList, isEmpty);
    });
  });
}
