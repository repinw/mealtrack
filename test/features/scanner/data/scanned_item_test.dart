import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/discount.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';

void main() {
  group('ScannedItem', () {
    test('should initialize with mutable discounts list by default', () {
      final item = ScannedItem(name: 'Test Item', totalPrice: 1.99);

      expect(item.discounts, isEmpty);

      // Critical check: This would throw UnsupportedError if list was const []
      item.discounts.add(Discount(name: 'Rabatt', amount: 0.5));

      expect(item.discounts.length, 1);
    });

    test('should use identity equality (not value equality)', () {
      final item1 = ScannedItem(name: 'Milk', totalPrice: 1.0);
      final item2 = ScannedItem(name: 'Milk', totalPrice: 1.0);

      // Da ScannedItem mutable ist, sind zwei Instanzen ungleich (Identity)
      expect(item1, isNot(equals(item2)));
    });

    test('fromJson should parse correctly and return mutable list', () {
      final json = {
        'name': 'Butter',
        'quantity': 2,
        'totalPrice': 3.50,
        'unitPrice': 1.75,
        'weight': '250g',
        'isLowConfidence': true,
        'storeName': 'Aldi',
        'discounts': [
          {'name': 'Sale', 'amount': 0.50},
        ],
      };

      final item = ScannedItem.fromJson(json);

      expect(item.name, 'Butter');
      expect(item.quantity, 2);
      expect(item.totalPrice, 3.50);
      expect(item.unitPrice, 1.75);
      expect(item.weight, '250g');
      expect(item.isLowConfidence, isTrue);
      expect(item.storeName, 'Aldi');
      expect(item.discounts.length, 1);
      expect(item.discounts.first.name, 'Sale');

      // Check mutability after JSON parsing
      item.discounts.add(Discount(name: 'Coupon', amount: 0.20));
      expect(item.discounts.length, 2);
    });

    test('fromJson handles missing optional fields', () {
      final json = {'name': 'Bread', 'totalPrice': 2.0};

      final item = ScannedItem.fromJson(json);

      expect(item.name, 'Bread');
      expect(item.quantity, 1); // Default
      expect(item.totalPrice, 2.0);
      expect(item.discounts, isEmpty);

      // Ensure list is mutable even if missing in JSON
      item.discounts.add(Discount(name: 'D', amount: 0.1));
      expect(item.discounts, isNotEmpty);
    });

    test('fromJson throws when required fields are missing', () {
      // Missing 'name'
      final json1 = {'totalPrice': 2.0};
      // Missing 'totalPrice'
      final json2 = {'name': 'Bread'};

      expect(() => ScannedItem.fromJson(json1), throwsA(isA<TypeError>()));
      expect(() => ScannedItem.fromJson(json2), throwsA(isA<TypeError>()));
    });

    test('toString contains all fields', () {
      final item = ScannedItem(
        name: 'Test',
        totalPrice: 10,
        storeName: 'TestStore',
        isLowConfidence: true,
      );

      final str = item.toString();
      expect(str, contains('TestStore'));
      expect(str, contains('isLowConfidence: true'));
    });

    group('Business Logic', () {
      test('calculateEffectivePriceForQuantity uses existing unitPrice', () {
        final item = ScannedItem(
          name: 'Test',
          totalPrice: 10.0,
          quantity: 2,
          unitPrice: 5.0,
          discounts: [const Discount(name: 'D', amount: 1.0)],
        );

        // Unit price 5.0 * 3 = 15.0. Minus discount 1.0 = 14.0
        expect(item.calculateEffectivePriceForQuantity(3), 14.0);
      });

      test('calculateEffectivePriceForQuantity derives unitPrice if missing', () {
        final item = ScannedItem(
          name: 'Test',
          totalPrice: 10.0, // Implies unit price 5.0
          quantity: 2,
          discounts: [const Discount(name: 'D', amount: 1.0)],
        );

        // Derived unit price 5.0 * 4 = 20.0. Minus discount 1.0 = 19.0
        expect(item.calculateEffectivePriceForQuantity(4), 19.0);
      });

      test('updateFromUser updates fields and recalculates prices correctly', () {
        final item = ScannedItem(
          name: 'Old Name',
          totalPrice: 10.0,
          quantity: 2,
          isLowConfidence: true,
          discounts: [const Discount(name: 'D', amount: 2.0)],
        );

        // User inputs:
        // Quantity: 5
        // Displayed Price (Effective): 48.0
        // (Implies Gross Total = 48.0 + 2.0 = 50.0)
        // (Implies Unit Price = 50.0 / 5 = 10.0)

        item.updateFromUser(
          name: 'New Name',
          weight: '1kg',
          displayedPrice: 48.0,
          quantity: 5,
        );

        expect(item.name, 'New Name');
        expect(item.weight, '1kg');
        expect(item.quantity, 5);
        expect(item.isLowConfidence, false);
        expect(item.totalPrice, 50.0); // 48 + 2
        expect(item.unitPrice, 10.0); // 50 / 5
      });

      test('updateFromUser handles zero quantity gracefully', () {
        final item = ScannedItem(name: 'A', totalPrice: 10.0, quantity: 1);

        item.updateFromUser(
          name: 'A',
          weight: null,
          displayedPrice: 5.0,
          quantity: 0,
        );

        expect(item.quantity, 0);
        expect(item.totalPrice, 5.0); // No discount
        expect(item.unitPrice, 5.0); // Fallback to total if qty is 0
      });

      test(
          'calculateEffectivePriceForQuantity returns non-negative price when base quantity is 0',
          () {
        final item = ScannedItem(
          name: 'Test',
          totalPrice: 0.0, // For qty 0, price should be 0
          quantity: 0,
          discounts: [const Discount(name: 'D', amount: 1.0)],
        );

        // Should not return a negative price.
        expect(item.calculateEffectivePriceForQuantity(3), isNonNegative);
      });
    });
  });
}
