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
    final testDate = DateTime(2025, 1, 1);
    // ignore: invalid_use_of_internal_member
    final item1 = FridgeItem(
      id: '1',
      name: 'Item 1',
      entryDate: testDate,
      storeName: 'Store A',
      quantity: 1,
    );
    // ignore: invalid_use_of_internal_member
    final item2 = FridgeItem(
      id: '2',
      name: 'Item 2',
      entryDate: testDate,
      storeName: 'Store B',
      quantity: 2,
    );

    test('saveItems persists items to SharedPreferences', () async {
      final items = [item1, item2];

      await service.saveItems(items);

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('inventory_data');

      expect(jsonString, isNotNull);
      final decoded = jsonDecode(jsonString!) as List;
      expect(decoded.length, 2);
      expect(decoded[0]['id'], '1');
      expect(decoded[1]['id'], '2');
    });

    test('loadItems returns empty list when storage is empty', () async {
      final items = await service.loadItems();
      expect(items, isEmpty);
    });

    test(
      'loadItems returns list of FridgeItems when storage has data',
      () async {
        final itemsToSave = [item1, item2];
        // Pre-populate SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(
          itemsToSave.map((e) => e.toJson()).toList(),
        );
        await prefs.setString('inventory_data', jsonString);

        final loadedItems = await service.loadItems();

        expect(loadedItems.length, 2);
        expect(loadedItems[0], item1);
        expect(loadedItems[1], item2);
      },
    );

    test('loadItems throws FormatException on invalid JSON', () async {
      final prefs = await SharedPreferences.getInstance();
      // Save invalid JSON
      await prefs.setString('inventory_data', '{ invalid_json }');

      expect(() => service.loadItems(), throwsA(isA<FormatException>()));
    });
  });
}
