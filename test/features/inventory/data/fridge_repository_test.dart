import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import '../../../shared/test_helpers.dart';

void main() {
  late FridgeRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late CollectionReference<Map<String, dynamic>> collection;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    collection = fakeFirestore
        .collection('users')
        .doc('uid')
        .collection('inventory');
    repository = FridgeRepository(collection);
  });

  group('FridgeRepository', () {
    test('addItems adds items to collection', () async {
      final item = createTestFridgeItem(
        name: 'Banana',
        storeName: 'Store',
        quantity: 3,
      );
      await repository.addItems([item]);

      final snapshot = await collection.doc(item.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['name'], 'Banana');
    });

    test('updateQuantity updates item', () async {
      final item = createTestFridgeItem(
        name: 'TestItem',
        storeName: 'TestStore',
        quantity: 1,
      );
      await repository.addItems([item]);

      await repository.updateQuantity(item, -1);

      final snapshot = await collection.doc(item.id).get();
      final updatedItem = FridgeItem.fromJson(snapshot.data()!);

      expect(updatedItem.quantity, 0);
      expect(updatedItem.isConsumed, true); // computed from quantity == 0
    });

    test('getItems returns items', () async {
      final item = createTestFridgeItem(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );
      await repository.addItems([item]);

      final result = await repository.getItems();

      expect(result.length, 1);
      expect(result.first.id, item.id);
    });

    test('updateItem updates item', () async {
      final item = createTestFridgeItem(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );
      await repository.addItems([item]);

      final updated = item.copyWith(name: 'Green Apple');
      await repository.updateItem(updated);

      final snapshot = await collection.doc(item.id).get();
      expect(snapshot.data()!['name'], 'Green Apple');
    });

    test('deleteItem removes item', () async {
      final item = createTestFridgeItem(
        name: 'Apple',
        storeName: 'Store',
        quantity: 1,
      );
      await repository.addItems([item]);

      await repository.deleteItem(item.id);

      final snapshot = await collection.doc(item.id).get();
      expect(snapshot.exists, isFalse);
    });

    test('deleteAllItems removes all items', () async {
      final item1 = createTestFridgeItem(name: 'Apple', storeName: 'Store');
      final item2 = createTestFridgeItem(name: 'Banana', storeName: 'Store');
      await repository.addItems([item1, item2]);

      await repository.deleteAllItems();

      final snapshot = await collection.get();
      expect(snapshot.docs.isEmpty, isTrue);
    });

    test('getAvailableItems returns only items with quantity > 0', () async {
      final item1 = createTestFridgeItem(
        name: 'Apple',
        storeName: 'Store',
        quantity: 1,
      );
      final item2 = createTestFridgeItem(
        name: 'Banana',
        storeName: 'Store',
        quantity: 1,
      ).adjustQuantity(-1);
      await repository.addItems([item1, item2]);

      final result = await repository.getAvailableItems();
      expect(result.length, 1);
      expect(result.first.name, 'Apple');
    });

    test('getGroupedItems groups by receiptId', () async {
      final item1 = createTestFridgeItem(
        name: 'Apple',
        storeName: 'Store',
        receiptId: 'r1',
      );
      final item2 = createTestFridgeItem(
        name: 'Banana',
        storeName: 'Store',
        receiptId: 'r1',
      );
      final item3 = createTestFridgeItem(
        name: 'Orange',
        storeName: 'Store',
        receiptId: 'r2',
      );
      await repository.addItems([item1, item2, item3]);

      final result = await repository.getGroupedItems();
      expect(result.length, 2);
    });
  });
}
