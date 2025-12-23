import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorageService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = LocalStorageService();
  });

  group('LocalStorageService', () {
    final fixedDate = DateTime(2023, 1, 1);
    final item1 = FridgeItem.create(
      name: 'Apple',
      storeName: 'Store A',
      quantity: 5,
      now: () => fixedDate,
    );
    final item2 = FridgeItem.create(
      name: 'Banana',
      storeName: 'Store B',
      quantity: 3,
      now: () => fixedDate,
    );

    test('saveItems saves encoded json to SharedPreferences', () async {
      await service.saveItems([item1, item2]);

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('inventory_data');

      expect(jsonString, isNotNull);
      final decoded = jsonDecode(jsonString!) as List;
      expect(decoded.length, 2);
      expect(decoded[0]['name'], 'Apple');
      expect(decoded[1]['name'], 'Banana');
    });

    test('loadItems returns empty list when no data exists', () async {
      final items = await service.loadItems();
      expect(items, isEmpty);
    });

    test('loadItems returns list of FridgeItems when data exists', () async {
      await service.saveItems([item1, item2]);

      final items = await service.loadItems();

      expect(items.length, 2);
      expect(items, [item1, item2]);
    });

    test('loadItems throws FormatException when JSON is invalid', () async {
      SharedPreferences.setMockInitialValues({
        'inventory_data': 'invalid_json_string',
      });

      expect(() => service.loadItems(), throwsA(isA<FormatException>()));
    });

    test('deleteAllItems removes data from SharedPreferences', () async {
      await service.saveItems([item1]);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('inventory_data'), isNotNull);

      await service.deleteAllItems();

      expect(prefs.getString('inventory_data'), isNull);
    });
  });
}
