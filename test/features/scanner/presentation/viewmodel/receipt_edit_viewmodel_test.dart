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

// Helper functions to reduce test boilerplate
FridgeItem _createNormalItem({
  String id = 'normal1',
  String name = 'Product',
  String storeName = 'Store',
  double unitPrice = 10.0,
  int quantity = 1,
}) => FridgeItem(
  id: id,
  name: name,
  storeName: storeName,
  unitPrice: unitPrice,
  quantity: quantity,
  entryDate: DateTime.now(),
);

FridgeItem _createDiscountItem({
  String id = 'discount1',
  String name = 'Discount 10%',
  double unitPrice = 1.0,
}) => FridgeItem(
  id: id,
  name: name,
  storeName: 'Store',
  unitPrice: unitPrice,
  quantity: 1,
  entryDate: DateTime.now(),
  isDiscount: true,
  isDeposit: true,
);

FridgeItem _createDepositItem({
  String id = 'pfand1',
  String name = 'Pfand',
  double unitPrice = 0.25,
}) => FridgeItem(
  id: id,
  name: name,
  storeName: 'Store',
  unitPrice: unitPrice,
  quantity: 1,
  entryDate: DateTime.now(),
  isDeposit: true,
  isDiscount: false,
);

ProviderContainer _createContainer(List<FridgeItem> items) {
  return ProviderContainer(
    overrides: [
      scannerViewModelProvider.overrideWith(
        () => MockScannerViewModel(AsyncValue.data(items)),
      ),
    ],
  );
}

void main() {
  group('ReceiptEditViewModel', () {
    final item1 = _createNormalItem(
      id: '1',
      name: 'Apple',
      storeName: 'Store A',
      unitPrice: 1.50,
      quantity: 2,
    );

    final item2 = _createNormalItem(
      id: '2',
      name: 'Banana',
      storeName: 'Store A',
      unitPrice: 0.50,
      quantity: 4,
    );

    test('initializes with empty list when home state has no data', () {
      final container = _createContainer([]);
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.items, isEmpty);
      expect(state.total, 0.0);
      expect(state.totalQuantity, 0);
    });

    test('initializes with provided items from ScannerViewModel', () {
      final container = _createContainer([item1, item2]);
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.items.length, 2);
      expect(state.items, containsAll([item1, item2]));
    });

    test('calculates total correctly', () {
      final container = _createContainer([item1, item2]);
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.total, 5.0);
    });

    test('calculates totalQuantity correctly', () {
      final container = _createContainer([item1, item2]);
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.totalQuantity, 6);
    });

    test('initialStoreName returns the first non-empty store name', () {
      final itemEmptyStore = item1.copyWith(storeName: '');
      final container = _createContainer([itemEmptyStore, item2]);
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.initialStoreName, 'Store A');
    });

    test('initialStoreName returns default value if no store name found', () {
      final itemEmptyStore1 = item1.copyWith(storeName: '');
      final itemEmptyStore2 = item2.copyWith(storeName: '');
      final container = _createContainer([itemEmptyStore1, itemEmptyStore2]);
      addTearDown(container.dispose);

      final state = container.read(receiptEditViewModelProvider);

      expect(state.initialStoreName, '');
    });

    test('updateMerchantName updates store name for all items', () {
      final container = _createContainer([item1, item2]);
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
      final container = _createContainer([item1, item2]);
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);
      notifier.deleteItem(0);

      final updatedState = container.read(receiptEditViewModelProvider);
      expect(updatedState.items.length, 1);
      expect(updatedState.items.first.name, 'Banana');
    });

    test('updateItem replaces item at index', () {
      final container = _createContainer([item1]);
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      final newItem = item1.copyWith(name: 'Green Apple');
      notifier.updateItem(0, newItem);

      final updatedState = container.read(receiptEditViewModelProvider);
      expect(updatedState.items.first.name, 'Green Apple');
    });

    test('updateReceiptDate updates receipt date for all items', () {
      final container = _createContainer([item1, item2]);
      addTearDown(container.dispose);

      final notifier = container.read(receiptEditViewModelProvider.notifier);

      final newDate = DateTime(2025, 12, 25);
      notifier.updateReceiptDate(newDate);

      final updatedState = container.read(receiptEditViewModelProvider);
      expect(
        updatedState.items.every((item) => item.receiptDate == newDate),
        isTrue,
      );
    });

    test('updateReceiptDate ensures state immutability', () {
      final container = _createContainer([item1]);
      addTearDown(container.dispose);

      final prevState = container.read(receiptEditViewModelProvider);
      final notifier = container.read(receiptEditViewModelProvider.notifier);

      final newDate = DateTime(2025, 12, 25);
      notifier.updateReceiptDate(newDate);

      final updatedState = container.read(receiptEditViewModelProvider);

      expect(updatedState, isNot(same(prevState)));
      expect(updatedState.items, isNot(same(prevState.items)));
      expect(prevState.items.first.receiptDate, isNot(newDate));
    });

    group('deleteItem cascade behavior', () {
      test('removes trailing discount items when normal item is deleted', () {
        final normalItem = _createNormalItem();
        final discountItem = _createDiscountItem();
        final anotherNormalItem = _createNormalItem(
          id: 'normal2',
          name: 'Another',
        );

        final container = _createContainer([
          normalItem,
          discountItem,
          anotherNormalItem,
        ]);
        addTearDown(container.dispose);

        final notifier = container.read(receiptEditViewModelProvider.notifier);
        notifier.deleteItem(0);

        final updatedState = container.read(receiptEditViewModelProvider);
        expect(updatedState.items.length, 1);
        expect(updatedState.items.first.id, 'normal2');
      });

      test(
        'only removes single discount when discount is deleted directly',
        () {
          final normalItem = _createNormalItem();
          final discountItem = _createDiscountItem();

          final container = _createContainer([normalItem, discountItem]);
          addTearDown(container.dispose);

          final notifier = container.read(
            receiptEditViewModelProvider.notifier,
          );
          notifier.deleteItem(1);

          final updatedState = container.read(receiptEditViewModelProvider);
          expect(updatedState.items.length, 1);
          expect(updatedState.items.first.id, 'normal1');
        },
      );
    });

    group('getItemsForSave', () {
      test('Happy Path: returns normal items unchanged', () {
        final normalItem1 = _createNormalItem(id: 'item1', name: 'Apple');
        final normalItem2 = _createNormalItem(id: 'item2', name: 'Banana');

        final container = _createContainer([normalItem1, normalItem2]);
        addTearDown(container.dispose);

        final notifier = container.read(receiptEditViewModelProvider.notifier);
        final result = notifier.getItemsForSave();

        expect(result.length, 2);
        expect(result[0].id, 'item1');
        expect(result[1].id, 'item2');
      });

      test('Merge Logic: discount is merged into preceding normal item', () {
        final normalItem = _createNormalItem(name: 'Expensive Item');
        final discountItem = _createDiscountItem(
          name: '10% Rabatt',
          unitPrice: 1.0,
        );

        final container = _createContainer([normalItem, discountItem]);
        addTearDown(container.dispose);

        final notifier = container.read(receiptEditViewModelProvider.notifier);
        final result = notifier.getItemsForSave();

        expect(result.length, 1);
        expect(result.first.id, 'normal1');
        expect(result.first.discounts['10% Rabatt'], 1.0);
      });

      test('Deposit Logic: deposit items (Pfand) are filtered out', () {
        final normalItem = _createNormalItem(id: 'bottle1', name: 'Bottle');
        final depositItem = _createDepositItem();

        final container = _createContainer([normalItem, depositItem]);
        addTearDown(container.dispose);

        final notifier = container.read(receiptEditViewModelProvider.notifier);
        final result = notifier.getItemsForSave();

        expect(result.length, 1);
        expect(result.first.id, 'bottle1');
      });

      test('Orphan Discount: discount without predecessor is ignored', () {
        final orphanDiscount = _createDiscountItem(
          id: 'orphan1',
          name: 'Orphan Discount',
        );
        final normalItem = _createNormalItem(name: 'Normal Item');

        final container = _createContainer([orphanDiscount, normalItem]);
        addTearDown(container.dispose);

        final notifier = container.read(receiptEditViewModelProvider.notifier);
        final result = notifier.getItemsForSave();

        expect(result.length, 1);
        expect(result.first.id, 'normal1');
        expect(result.first.discounts, isEmpty);
      });

      test('Multiple discounts are merged into same item', () {
        final normalItem = _createNormalItem(id: 'item1', name: 'Item');
        final discount1 = _createDiscountItem(
          id: 'd1',
          name: 'Rabatt 1',
          unitPrice: 2.0,
        );
        final discount2 = _createDiscountItem(
          id: 'd2',
          name: 'Rabatt 2',
          unitPrice: 3.0,
        );

        final container = _createContainer([normalItem, discount1, discount2]);
        addTearDown(container.dispose);

        final notifier = container.read(receiptEditViewModelProvider.notifier);
        final result = notifier.getItemsForSave();

        expect(result.length, 1);
        expect(result.first.discounts.length, 2);
        expect(result.first.discounts['Rabatt 1'], 2.0);
        expect(result.first.discounts['Rabatt 2'], 3.0);
      });
    });
  });
}
