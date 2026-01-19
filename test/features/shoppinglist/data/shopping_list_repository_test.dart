import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/core/config/app_config.dart';

void main() {
  late ShoppingListRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  const testUid = 'test-user-id';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ShoppingListRepository(fakeFirestore, testUid);
  });

  group('ShoppingListRepository', () {
    test('addItem adds an item to the collection', () async {
      final item = ShoppingListItem.create(name: 'Apples', unitPrice: 1.99);
      await repository.addItem(item);

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .doc(item.id)
          .get();

      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['name'], 'Apples');
      expect(snapshot.data()!['unitPrice'], 1.99);
    });

    test('updateItem updates an existing item (merge)', () async {
      final item = ShoppingListItem.create(
        name: 'Apples',
        quantity: 1,
        unitPrice: 1.50,
      );
      await repository.addItem(item);

      final updatedItem = item.copyWith(quantity: 5, unitPrice: 2.00);
      await repository.updateItem(updatedItem);

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .doc(item.id)
          .get();

      expect(snapshot.data()!['quantity'], 5);
      expect(snapshot.data()!['name'], 'Apples');
      expect(snapshot.data()!['unitPrice'], 2.00);
    });

    test('deleteItem removes an item', () async {
      final item = ShoppingListItem.create(name: 'Apples');
      await repository.addItem(item);

      await repository.deleteItem(item.id);

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .doc(item.id)
          .get();

      expect(snapshot.exists, isFalse);
    });

    test('clearList removes all items from the collection', () async {
      final item1 = ShoppingListItem.create(name: 'Apples');
      final item2 = ShoppingListItem.create(name: 'Bananas');
      await repository.addItem(item1);
      await repository.addItem(item2);

      await repository.clearList();

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();

      expect(snapshot.docs.isEmpty, isTrue);
    });

    test('watchItems returns a sorted stream of items', () async {
      final itemA = ShoppingListItem.create(name: 'Bananas');
      final itemB = ShoppingListItem.create(name: 'Apples');
      final itemC = ShoppingListItem.create(name: 'Cherries');

      await repository.addItem(itemA);
      await repository.addItem(itemB);
      await repository.addItem(itemC);

      final stream = repository.watchItems();
      final firstResult = await stream.first;

      expect(firstResult.length, 3);
      expect(firstResult[0].name, 'Apples');
      expect(firstResult[1].name, 'Bananas');
      expect(firstResult[2].name, 'Cherries');
    });

    test('clearList handles more than 500 items (Batch Limit)', () async {
      // Add 501 items
      for (var i = 0; i < 501; i++) {
        final item = ShoppingListItem.create(name: 'Item $i');
        await repository.addItem(item);
      }

      final beforeSnapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();
      expect(beforeSnapshot.docs.length, 501);

      await repository.clearList();

      final afterSnapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();
      expect(afterSnapshot.docs.isEmpty, isTrue);
    });

    test('updateItem preserves fields not in model (merge: true)', () async {
      final item = ShoppingListItem.create(name: 'Apples', quantity: 1);
      await repository.addItem(item);

      // Manually add a field to Firestore that is not in the model
      await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .doc(item.id)
          .set({'extra_field': 'preserve_me'}, SetOptions(merge: true));

      final updatedItem = item.copyWith(quantity: 10);
      await repository.updateItem(updatedItem);

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .doc(item.id)
          .get();

      expect(snapshot.data()!['quantity'], 10);
      expect(snapshot.data()!['extra_field'], 'preserve_me');
    });
    test('addOrMergeItem merges items case-insensitively', () async {
      // 1. Add "Milk"
      await repository.addOrMergeItem(
        name: 'Milk',
        brand: 'Farm',
        quantity: 1,
        unitPrice: 1.0,
      );

      // Verify created
      final snapshot1 = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();
      expect(snapshot1.docs.length, 1);
      expect(snapshot1.docs.first.data()['name'], 'Milk');
      expect(snapshot1.docs.first.data()['quantity'], 1);
      expect(snapshot1.docs.first.data()['normalizedName'], 'milk');

      // 2. Add "milk" (lowercase) - should merge
      await repository.addOrMergeItem(
        name: 'milk',
        brand: 'Farm',
        quantity: 2,
        unitPrice: 1.5,
      );

      final snapshot2 = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();

      // Should still be 1 item
      expect(snapshot2.docs.length, 1);
      final doc = snapshot2.docs.first.data();
      expect(
        doc['name'],
        'Milk',
      ); // Original name preserved (or updated if logic changed, but here we expect original doc reused)
      expect(doc['quantity'], 3); // 1 + 2
      expect(doc['unitPrice'], 1.5);
      expect(doc['normalizedName'], 'milk');
    });

    test('addOrMergeItem creates new item if brand differs', () async {
      await repository.addOrMergeItem(
        name: 'Milk',
        brand: 'Brand A',
        quantity: 1,
        unitPrice: 1.0,
      );

      await repository.addOrMergeItem(
        name: 'Milk',
        brand: 'Brand B',
        quantity: 1,
        unitPrice: 1.0,
      );

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();

      expect(snapshot.docs.length, 2);
    });
  });
}
