import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';

void main() {
  group('ScannedItem', () {
    test('supports duplicate discount names', () {
      final json = {
        'name': 'Test Item',
        'quantity': 1,
        'totalPrice': 10.0,
        'discounts': [
          {'name': 'Rabatt', 'amount': 1.0},
          {'name': 'Rabatt', 'amount': 2.0},
        ],
      };

      final item = ScannedItem.fromJson(json);

      expect(item.discounts.length, 2);
      expect(item.discounts[0], {'name': 'Rabatt', 'amount': 1.0});
      expect(item.discounts[1], {'name': 'Rabatt', 'amount': 2.0});
    });

    test('discounts list is immutable', () {
      final json = {
        'name': 'Test Item',
        'quantity': 1,
        'totalPrice': 10.0,
        'discounts': [
          {'name': 'Rabatt', 'amount': 1.0},
        ],
      };

      final item = ScannedItem.fromJson(json);

      expect(
        () => item.discounts.add({'name': 'New', 'amount': 5.0}),
        throwsUnsupportedError,
      );
    });

    test('fromJson handles missing discounts', () {
      final json = {'name': 'Test Item', 'quantity': 1, 'totalPrice': 10.0};

      final item = ScannedItem.fromJson(json);

      expect(item.discounts, isEmpty);
    });

    test('equality works with discounts', () {
      final item1 = ScannedItem(
        name: 'Item',
        totalPrice: 10.0,
        discounts: const [
          {'name': 'D1', 'amount': 1.0},
        ],
      );
      final item2 = ScannedItem(
        name: 'Item',
        totalPrice: 10.0,
        discounts: const [
          {'name': 'D1', 'amount': 1.0},
        ],
      );
      final item3 = ScannedItem(
        name: 'Item',
        totalPrice: 10.0,
        discounts: const [
          {'name': 'D1', 'amount': 2.0},
        ],
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });
  });
}
