import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/exceptions/storage_exception.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorageService service;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    service = container.read(localStorageServiceProvider);
  });

  tearDown(() {
    container.dispose();
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

    test(
      'loadItems throws StorageException and backs up data when JSON is invalid',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('inventory_data', 'invalid_json_string');

        final manualService = LocalStorageService(Future.value(prefs));

        try {
          await manualService.loadItems();
          fail('Should have thrown StorageException');
        } on StorageException catch (_) {}

        final keys = prefs.getKeys();
        final backupKey = keys.firstWhere(
          (k) => k.startsWith('inventory_data_corrupt_'),
          orElse: () => '',
        );

        expect(backupKey, isNotEmpty, reason: 'Backup key not found');
        expect(prefs.getString(backupKey), 'invalid_json_string');
      },
    );

    test('deleteAllItems removes data from SharedPreferences', () async {
      await service.saveItems([item1]);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('inventory_data'), isNotNull);

      await service.deleteAllItems();

      expect(prefs.getString('inventory_data'), isNull);
    });
  });
}
