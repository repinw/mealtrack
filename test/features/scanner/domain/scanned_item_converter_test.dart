import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/discount.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/domain/scanned_item_converter.dart';

void main() {
  group('ScannedItemConverter', () {
    test('toFridgeItems converts valid items correctly', () {
      final scannedItems = [
        ScannedItem(
          name: 'Milk',
          quantity: 2,
          totalPrice: 3.0,
          weight: '1L',
          storeName: 'OriginalStore', // Should be overridden by argument
        ),
        ScannedItem(name: 'Bread', quantity: 1, totalPrice: 2.5),
      ];
      const targetStoreName = 'SuperMart';

      final result = ScannedItemConverter.toFridgeItems(
        scannedItems,
        targetStoreName,
      );

      expect(result.length, 2);

      final milk = result[0];
      expect(milk.rawText, 'Milk');
      expect(milk.quantity, 2);
      expect(milk.unitPrice, 1.5); // 3.0 / 2
      expect(milk.weight, '1L');
      expect(milk.storeName, targetStoreName);
      expect(milk.receiptId, isNotEmpty);

      final bread = result[1];
      expect(bread.rawText, 'Bread');
      expect(bread.quantity, 1);
      expect(bread.unitPrice, 2.5);
      expect(bread.storeName, targetStoreName);
      // Receipt ID should be consistent across items from the same conversion
      expect(bread.receiptId, milk.receiptId);
    });

    test('toFridgeItems filters out items with zero quantity', () {
      final scannedItems = [
        ScannedItem(name: 'Valid', quantity: 1, totalPrice: 1.0),
        ScannedItem(name: 'Invalid', quantity: 0, totalPrice: 0.0),
      ];

      final result = ScannedItemConverter.toFridgeItems(scannedItems, 'Store');

      expect(result.length, 1);
      expect(result.first.rawText, 'Valid');
    });

    test('toFridgeItems maps discounts correctly', () {
      final scannedItems = [
        ScannedItem(
          name: 'Item with Discount',
          quantity: 1,
          totalPrice: 10.0,
          discounts: [Discount(name: 'Promo', amount: 2.0)],
        ),
      ];

      final result = ScannedItemConverter.toFridgeItems(scannedItems, 'Store');

      expect(result.length, 1);
      final item = result.first;
      expect(item.discounts.length, 1);
      expect(item.discounts.first.name, 'Promo');
      expect(item.discounts.first.amount, 2.0);
    });

    test('toFridgeItems handles empty input list', () {
      final result = ScannedItemConverter.toFridgeItems([], 'Store');
      expect(result, isEmpty);
    });
  });
}
