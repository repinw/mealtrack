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
  });
}
