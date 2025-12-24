import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_controller.dart';

void main() {
  group('ReceiptEditController', () {
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

    test('initializes with empty list when null is passed', () {
      final controller = ReceiptEditController(null);
      expect(controller.items, isEmpty);
      expect(controller.total, 0.0);
      expect(controller.totalQuantity, 0);
    });

    test('initializes with provided items', () {
      final controller = ReceiptEditController([item1, item2]);
      expect(controller.items.length, 2);
      expect(controller.items, containsAll([item1, item2]));
    });

    test('calculates total correctly', () {
      final controller = ReceiptEditController([item1, item2]);
      // (1.50 * 2) + (0.50 * 4) = 3.0 + 2.0 = 5.0
      expect(controller.total, 5.0);
    });

    test('calculates totalQuantity correctly', () {
      final controller = ReceiptEditController([item1, item2]);
      // 2 + 4 = 6
      expect(controller.totalQuantity, 6);
    });

    test('initialStoreName returns the first non-empty store name', () {
      final itemEmptyStore = item1.copyWith(storeName: '');
      final controller = ReceiptEditController([itemEmptyStore, item2]);

      expect(controller.initialStoreName, 'Store A');
    });

    test('initialStoreName returns default value if no store name found', () {
      final itemEmptyStore1 = item1.copyWith(storeName: '');
      final itemEmptyStore2 = item2.copyWith(storeName: '');
      final controller = ReceiptEditController([
        itemEmptyStore1,
        itemEmptyStore2,
      ]);

      expect(controller.initialStoreName, 'Ladenname');
    });

    test('updateMerchantName updates store name for all items', () {
      final controller = ReceiptEditController([item1, item2]);
      const newStoreName = 'Supermarket B';

      controller.updateMerchantName(newStoreName);

      expect(
        controller.items.every((item) => item.storeName == newStoreName),
        isTrue,
      );
    });

    test('updateMerchantName notifies listeners when changes occur', () {
      final controller = ReceiptEditController([item1]);
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.updateMerchantName('New Store');
      expect(notified, isTrue);
    });

    test('deleteItem removes item at index and notifies listeners', () {
      final controller = ReceiptEditController([item1, item2]);
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.deleteItem(0);

      expect(controller.items.length, 1);
      expect(controller.items.first, item2);
      expect(notified, isTrue);
    });

    test('updateItem replaces item at index and notifies listeners', () {
      final controller = ReceiptEditController([item1]);
      final newItem = item1.copyWith(name: 'Green Apple');

      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.updateItem(0, newItem);

      expect(controller.items.first.name, 'Green Apple');
      expect(notified, isTrue);
    });
  });
}
