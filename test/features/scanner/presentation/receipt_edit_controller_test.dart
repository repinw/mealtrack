import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_controller.dart';

void main() {
  group('ReceiptEditController', () {
    late ReceiptEditController controller;

    // Helper to create items for testing.
    // Adjust the constructor arguments below to match your actual FridgeItem definition.
    FridgeItem createItem({
      String name = 'Test Item',
      String storeName = '',
      double? unitPrice,
      int quantity = 1,
    }) {
      return FridgeItem(
        id: '',
        storeName: storeName,
        unitPrice: unitPrice,
        quantity: quantity,
        rawText: ""
        entryDate: DateTime(ye)
      );
    }

    test('initialStoreName returns the first non-empty store name', () {
      final items = [
        createItem(storeName: ''),
        createItem(storeName: 'Target'),
        createItem(storeName: 'Walmart'),
      ];
      controller = ReceiptEditController(items);
      expect(controller.initialStoreName, 'Target');
    });

    test('initialStoreName returns empty string if no store name found', () {
      final items = [createItem(storeName: ''), createItem(storeName: '')];
      controller = ReceiptEditController(items);
      expect(controller.initialStoreName, '');
    });

    test('initialStoreName returns empty string if list is empty', () {
      controller = ReceiptEditController([]);
      expect(controller.initialStoreName, '');
    });

    test('Calculate Total Sum with multiple quantities (Happy Path)', () {
      // Scenario: Calculate Total Sum with multiple quantities.
      // Setup: Item A (Price 10.0, Qty 2), Item B (Price 5.0, Qty 1).
      final items = [
        createItem(name: 'Item A', unitPrice: 10.0, quantity: 2),
        createItem(name: 'Item B', unitPrice: 5.0, quantity: 1),
      ];
      controller = ReceiptEditController(items);

      // Expectation: Total sum displayed is 25.0 (20 + 5).
      expect(controller.total, 25.0);
    });

    test(
      'Calculate Total Sum treats null unitPrice as 0.0 (Error Handling)',
      () {
        // Scenario: Null values in calculation.
        final items = [
          createItem(unitPrice: 10.0, quantity: 1),
          createItem(unitPrice: null, quantity: 5), // Should be treated as 0.0
        ];
        controller = ReceiptEditController(items);

        // Expectation: 10.0 + (0.0 * 5) = 10.0
        expect(controller.total, 10.0);
      },
    );

    test('totalQuantity sums up all quantities', () {
      final items = [createItem(quantity: 2), createItem(quantity: 3)];
      controller = ReceiptEditController(items);
      expect(controller.totalQuantity, 5);
    });

    test('updateMerchantName updates all items and notifies listeners', () {
      final items = [
        createItem(storeName: 'Old Store'),
        createItem(storeName: 'Old Store'),
      ];
      controller = ReceiptEditController(items);

      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.updateMerchantName('New Store');

      expect(notified, isTrue);
      expect(
        controller.items.every((item) => item.storeName == 'New Store'),
        isTrue,
      );
    });

    test('updateMerchantName does not notify if name is unchanged', () {
      final items = [createItem(storeName: 'Same Name')];
      controller = ReceiptEditController(items);

      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.updateMerchantName('Same Name');

      expect(notified, isFalse);
    });

    test('deleteItem removes item at index and notifies listeners', () {
      final items = [createItem(name: 'Item 1'), createItem(name: 'Item 2')];
      controller = ReceiptEditController(items);

      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.deleteItem(0);

      expect(notified, isTrue);
      expect(controller.items.length, 1);
      expect(controller.items.first.name, 'Item 2');
    });
  });
}
