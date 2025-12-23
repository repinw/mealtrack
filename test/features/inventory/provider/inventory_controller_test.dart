import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/inventory_providers.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:mealtrack/features/inventory/provider/inventory_controller.dart';
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
  });

  tearDown(() {
    container.dispose();
  });

  group('InventoryController', () {
    test('initial state is AsyncData(null)', () {
      final state = container.read(inventoryControllerProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('deleteAllItems calls service and invalidates providers', () async {
      when(() => mockStorageService.deleteAllItems()).thenAnswer((_) async {});

      await container
          .read(inventoryControllerProvider.notifier)
          .deleteAllItems();

      verify(() => mockStorageService.deleteAllItems()).called(1);
      expect(
        container.read(inventoryControllerProvider),
        const AsyncData<void>(null),
      );
    });

    test('deleteAllItems sets error state when service fails', () async {
      final exception = Exception('Delete failed');
      when(() => mockStorageService.deleteAllItems()).thenThrow(exception);

      await container
          .read(inventoryControllerProvider.notifier)
          .deleteAllItems();

      verify(() => mockStorageService.deleteAllItems()).called(1);
      expect(container.read(inventoryControllerProvider).hasError, isTrue);
    });
  });

  group('inventoryDisplayListProvider', () {
    final fixedDate = DateTime(2023, 1, 1, 12, 0, 0);
    final item1 = FridgeItem.create(
      name: 'Apple',
      storeName: 'Store A',
      quantity: 5,
      now: () => fixedDate,
    );
    final item2 = FridgeItem.create(
      name: 'Banana',
      storeName: 'Store A',
      quantity: 1,
      now: () => fixedDate,
    ).copyWith(quantity: 0, isConsumed: true);
    final item3 = FridgeItem.create(
      name: 'Carrot',
      storeName: 'Store B',
      quantity: 2,
      now: () => fixedDate,
    );

    test(
      'returns grouped items including consumed ones when filter is disabled',
      () async {
        when(
          () => mockStorageService.loadItems(),
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
        () => mockStorageService.loadItems(),
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
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      final displayList = await container.read(
        inventoryDisplayListProvider.future,
      );

      expect(displayList, isEmpty);
    });
  });
}
