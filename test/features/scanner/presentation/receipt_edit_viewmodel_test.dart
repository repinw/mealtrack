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
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize([]);
      final state = container.read(receiptEditViewModelProvider);

      expect(state.items, isEmpty);
      expect(state.total, 0.0);
      expect(state.totalQuantity, 0);
    });

    test('initializes with provided items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize([item1, item2]);
      final state = container.read(receiptEditViewModelProvider);

      expect(state.items.length, 2);
      expect(state.items, containsAll([item1, item2]));
    });

    test('calculates total correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize([item1, item2]);
      final state = container.read(receiptEditViewModelProvider);

      // (1.50 * 2) + (0.50 * 4) = 3.0 + 2.0 = 5.0
      expect(state.total, 5.0);
    });

    test('calculates totalQuantity correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize([item1, item2]);
      final state = container.read(receiptEditViewModelProvider);

      // 2 + 4 = 6
      expect(state.totalQuantity, 6);
    });

    test('initialStoreName returns the first non-empty store name', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final itemEmptyStore = item1.copyWith(storeName: '');
      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize([itemEmptyStore, item2]);
      final state = container.read(receiptEditViewModelProvider);

      expect(state.initialStoreName, 'Store A');
    });

    test('initialStoreName returns default value if no store name found', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final itemEmptyStore1 = item1.copyWith(storeName: '');
      final itemEmptyStore2 = item2.copyWith(storeName: '');
      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize([itemEmptyStore1, itemEmptyStore2]);
      final state = container.read(receiptEditViewModelProvider);

      expect(state.initialStoreName, 'Ladenname');
    });

    test('updateMerchantName updates store name for all items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = [item1, item2];
      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize(items);

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
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = [item1, item2];
      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize(items);

      notifier.deleteItem(0);

      // Read the state again after deletion
      final updatedState = container.read(receiptEditViewModelProvider);
      expect(updatedState.items.length, 1);
      expect(updatedState.items.first.name, 'Banana');
    });

    test('updateItem replaces item at index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = [item1];
      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize(items);

      final newItem = item1.copyWith(name: 'Green Apple');
      notifier.updateItem(0, newItem);

      // Read the state again after update
      final updatedState = container.read(receiptEditViewModelProvider);
      expect(updatedState.items.first.name, 'Green Apple');
    });

    test('calculates total with zero quantity items correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final itemZeroQty = item1.copyWith(quantity: 0, unitPrice: 10.0);
      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize([itemZeroQty, item2]);
      final state = container.read(receiptEditViewModelProvider);

      // (0 * 10.0) + (0.50 * 4) = 0 + 2.0 = 2.0
      expect(state.total, 2.0);
    });

    test('deleteItem updates total price', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = [
        item1,
        item2,
      ]; // item1 total: 3.0, item2 total: 2.0. Sum: 5.0

      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.initialize(items);

      notifier.deleteItem(0); // Remove item1

      // Read the state again
      final updatedState = container.read(receiptEditViewModelProvider);

      // Only item2 remains: 0.50 * 4 = 2.0
      expect(updatedState.total, 2.0);
    });

    test('re-initialization overwrites previous state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      // Initialize with item1
      notifier.initialize([item1]);
      var state = container.read(receiptEditViewModelProvider);
      expect(state.items.length, 1);
      expect(state.items.first.name, 'Apple');

      // Re-initialize with item2
      notifier.initialize([item2]);
      state = container.read(receiptEditViewModelProvider);
      expect(state.items.length, 1);
      expect(state.items.first.name, 'Banana');
    });
  });
}
