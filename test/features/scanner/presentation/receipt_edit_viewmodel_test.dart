import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_viewmodel.dart';

void main() {
  group('ReceiptEditViewModel', () {
    final item1 = FridgeItem(
      name: 'Apple',
      storeName: 'Store A',
      unitPrice: 1.50,
      quantity: 2,
      entryDate: DateTime.now(),
      id: '1',
    );

    final item2 = FridgeItem(
      name: 'Banana',
      storeName: 'Store A',
      unitPrice: 0.50,
      quantity: 4,
      entryDate: DateTime.now(),
      id: '2',
    );

    test('initializes with empty list when initialized with empty list', () {
      final container = ProviderContainer(
        overrides: [initialScannedItemsProvider.overrideWithValue([])],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.items, isEmpty);
      expect(state.total, 0.0);
      expect(state.totalQuantity, 0);
    });

    test('initializes with provided items', () {
      final container = ProviderContainer(
        overrides: [
          initialScannedItemsProvider.overrideWithValue([item1, item2]),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.items.length, 2);
      expect(state.items, containsAll([item1, item2]));
    });

    test('calculates total correctly', () {
      final container = ProviderContainer(
        overrides: [
          initialScannedItemsProvider.overrideWithValue([item1, item2]),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      // (1.50 * 2) + (0.50 * 4) = 3.0 + 2.0 = 5.0
      expect(state.total, 5.0);
    });

    test('calculates totalQuantity correctly', () {
      final container = ProviderContainer(
        overrides: [
          initialScannedItemsProvider.overrideWithValue([item1, item2]),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      // 2 + 4 = 6
      expect(state.totalQuantity, 6);
    });

    test('initialStoreName returns the first non-empty store name', () {
      final itemEmptyStore = item1.copyWith(storeName: '');
      final container = ProviderContainer(
        overrides: [
          initialScannedItemsProvider.overrideWithValue([
            itemEmptyStore,
            item2,
          ]),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.initialStoreName, 'Store A');
    });

    test('initialStoreName returns default value if no store name found', () {
      final itemEmptyStore1 = item1.copyWith(storeName: '');
      final itemEmptyStore2 = item2.copyWith(storeName: '');

      final container = ProviderContainer(
        overrides: [
          initialScannedItemsProvider.overrideWithValue([
            itemEmptyStore1,
            itemEmptyStore2,
          ]),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.initialStoreName, 'Ladenname');
    });

    test('updateMerchantName updates store name for all items', () {
      final items = [item1, item2];
      final container = ProviderContainer(
        overrides: [initialScannedItemsProvider.overrideWithValue(items)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);
      // Removed initialization via method

      const newStoreName = 'Supermarket B';
      notifier.updateMerchantName(newStoreName);

      // Read the state again after update
      final updatedState = container.read(receiptEditViewModelProvider);
      expect(
        updatedState.items.every((item) => item.storeName == newStoreName),
        isTrue,
      );
    });

    test('deleteItem removes item at index', () {
      final items = [item1, item2];
      final container = ProviderContainer(
        overrides: [initialScannedItemsProvider.overrideWithValue(items)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      notifier.deleteItem(0);

      // Read the state again after deletion
      final updatedState = container.read(receiptEditViewModelProvider);
      expect(updatedState.items.length, 1);
      expect(updatedState.items.first.name, 'Banana');
    });

    test('updateItem replaces item at index', () {
      final items = [item1];
      final container = ProviderContainer(
        overrides: [initialScannedItemsProvider.overrideWithValue(items)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      final newItem = item1.copyWith(name: 'Green Apple');
      notifier.updateItem(0, newItem);

      // Read the state again after update
      final updatedState = container.read(receiptEditViewModelProvider);
      expect(updatedState.items.first.name, 'Green Apple');
    });

    test('calculates total with zero quantity items correctly', () {
      final itemZeroQty = item1.copyWith(quantity: 0, unitPrice: 10.0);
      final container = ProviderContainer(
        overrides: [
          initialScannedItemsProvider.overrideWithValue([itemZeroQty, item2]),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      // (0 * 10.0) + (0.50 * 4) = 0 + 2.0 = 2.0
      expect(state.total, 2.0);
    });

    test('deleteItem updates total price', () {
      final items = [
        item1,
        item2,
      ]; // item1 total: 3.0, item2 total: 2.0. Sum: 5.0

      final container = ProviderContainer(
        overrides: [initialScannedItemsProvider.overrideWithValue(items)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      notifier.deleteItem(0); // Remove item1

      // Read the state again
      final updatedState = container.read(receiptEditViewModelProvider);

      // Only item2 remains: 0.50 * 4 = 2.0
      expect(updatedState.total, 2.0);
    });

    test(
      're-initialization via provider override is not possible at runtime but different containers allow different inits',
      () {
        // Since we got rid of initialize method, we can't "re-initialize" a live notifier.
        // We can only test that different containers start with different states.
        final container1 = ProviderContainer(
          overrides: [
            initialScannedItemsProvider.overrideWithValue([item1]),
          ],
        );

        final state1 = container1.read(receiptEditViewModelProvider);
        expect(state1.items.length, 1);
        expect(state1.items.first.name, 'Apple');

        final container2 = ProviderContainer(
          overrides: [
            initialScannedItemsProvider.overrideWithValue([item2]),
          ],
        );

        final state2 = container2.read(receiptEditViewModelProvider);
        expect(state2.items.length, 1);
        expect(state2.items.first.name, 'Banana');

        container1.dispose();
        container2.dispose();
      },
    );
  });
}
