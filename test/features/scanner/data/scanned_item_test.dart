import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';

void main() {
  group('ScannedItem', () {
    test('supports value equality', () {
      const item1 = ScannedItem(
        name: 'Apple',
        totalPrice: 1.99,
      );
      const item2 = ScannedItem(
        name: 'Apple',
        totalPrice: 1.99,
      );
      const item3 = ScannedItem(
        name: 'Banana',
        totalPrice: 0.99,
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });

    test('toString returns correct string representation', () {
      const item = ScannedItem(
        name: 'Milk',
        quantity: 2,
        totalPrice: 3.50,
        unitPrice: 1.75,
        weight: '1L',
        discounts: {'Sale': -0.50},
      );

      expect(
        item.toString(),
        'ScannedItem(name: Milk, quantity: 2, totalPrice: 3.5, unitPrice: 1.75, weight: 1L, discounts: {Sale: -0.5})',
      );
    });

    group('fromJson', () {
      test('parses valid json correctly', () {
        final json = {
          'name': 'Bread',
          'quantity': 1,
          'totalPrice': 2.49,
          'unitPrice': 2.49,
          'weight': '500g',
          'discounts': [
            {'name': 'Discount', 'amount': -0.50}
          ]
        };

        final item = ScannedItem.fromJson(json);

        expect(item.name, 'Bread');
        expect(item.quantity, 1);
        expect(item.totalPrice, 2.49);
        expect(item.unitPrice, 2.49);
        expect(item.weight, '500g');
        expect(item.discounts, {'Discount': -0.50});
      });

      test('handles missing optional fields with defaults', () {
        final json = {
          'name': 'Butter',
          'totalPrice': 1.99,
        };

        final item = ScannedItem.fromJson(json);

        expect(item.name, 'Butter');
        expect(item.quantity, 1); // Default
        expect(item.totalPrice, 1.99);
        expect(item.unitPrice, isNull);
        expect(item.weight, isNull);
        expect(item.discounts, isEmpty);
      });

      test('handles numeric type conversions (int to double)', () {
        final json = {
          'name': 'Cheese',
          'quantity': 2.0, // double in json
          'totalPrice': 5, // int in json
          'unitPrice': 2, // int in json
          'discounts': [
            {'name': 'Promo', 'amount': -1} // int in json
          ]
        };

        final item = ScannedItem.fromJson(json);

        expect(item.quantity, 2);
        expect(item.totalPrice, 5.0);
        expect(item.unitPrice, 2.0);
        expect(item.discounts['Promo'], -1.0);
      });
    });
  });
}
