import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/receipt_edit_viewmodel.dart';

// ignore: must_be_immutable
class MockScannerViewModel extends ScannerViewModel {
  final AsyncValue<List<FridgeItem>> overrideState;

  MockScannerViewModel(this.overrideState);

  @override
  Future<List<FridgeItem>> build() async {
    state = overrideState;
    return overrideState.value ?? [];
  }
}

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

    test(
      'initializes with empty list when home state has no data (or loading/error)',
      () {
        final container = ProviderContainer(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel(const AsyncValue.data([])),
            ),
          ],
        );
        addTearDown(container.dispose);

        final state = container.read(receiptEditViewModelProvider);

        expect(state.items, isEmpty);
        expect(state.total, 0.0);
        expect(state.totalQuantity, 0);
      },
    );

    test('initializes with provided items from ScannerViewModel', () {
      final container = ProviderContainer(
        overrides: [
          scannerViewModelProvider.overrideWith(
            () => MockScannerViewModel(AsyncValue.data([item1, item2])),
          ),
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
          scannerViewModelProvider.overrideWith(
            () => MockScannerViewModel(AsyncValue.data([item1, item2])),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.total, 5.0);
    });

    test('calculates totalQuantity correctly', () {
      final container = ProviderContainer(
        overrides: [
          scannerViewModelProvider.overrideWith(
            () => MockScannerViewModel(AsyncValue.data([item1, item2])),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.totalQuantity, 6);
    });

    test('initialStoreName returns the first non-empty store name', () {
      final itemEmptyStore = item1.copyWith(storeName: '');
      final container = ProviderContainer(
        overrides: [
          scannerViewModelProvider.overrideWith(
            () =>
                MockScannerViewModel(AsyncValue.data([itemEmptyStore, item2])),
          ),
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
          scannerViewModelProvider.overrideWith(
            () => MockScannerViewModel(
              AsyncValue.data([itemEmptyStore1, itemEmptyStore2]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.initialStoreName, 'Ladenname');
    });

    test('updateMerchantName updates store name for all items', () {
      final items = [item1, item2];
      final container = ProviderContainer(
        overrides: [
          scannerViewModelProvider.overrideWith(
            () => MockScannerViewModel(AsyncValue.data(items)),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      const newStoreName = 'Supermarket B';
      notifier.updateMerchantName(newStoreName);

      final updatedState = container.read(receiptEditViewModelProvider);
      expect(
        updatedState.items.every((item) => item.storeName == newStoreName),
        isTrue,
      );
    });

    test('deleteItem removes item at index', () {
      final items = [item1, item2];
      final container = ProviderContainer(
        overrides: [
          scannerViewModelProvider.overrideWith(
            () => MockScannerViewModel(AsyncValue.data(items)),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      notifier.deleteItem(0);

      final updatedState = container.read(receiptEditViewModelProvider);
      expect(updatedState.items.length, 1);
      expect(updatedState.items.first.name, 'Banana');
    });

    test('updateItem replaces item at index', () {
      final items = [item1];
      final container = ProviderContainer(
        overrides: [
          scannerViewModelProvider.overrideWith(
            () => MockScannerViewModel(AsyncValue.data(items)),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      final newItem = item1.copyWith(name: 'Green Apple');
      notifier.updateItem(0, newItem);

      final updatedState = container.read(receiptEditViewModelProvider);
      expect(updatedState.items.first.name, 'Green Apple');
    });
  });
}
