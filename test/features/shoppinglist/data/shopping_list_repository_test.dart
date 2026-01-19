import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';

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
          .collection('users')
          .doc(testUid)
          .collection('shopping_list')
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
          .collection('users')
          .doc(testUid)
          .collection('shopping_list')
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
          .collection('users')
          .doc(testUid)
          .collection('shopping_list')
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
          .collection('users')
          .doc(testUid)
          .collection('shopping_list')
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
          .collection('users')
          .doc(testUid)
          .collection('shopping_list')
          .get();
      expect(beforeSnapshot.docs.length, 501);

      await repository.clearList();

      final afterSnapshot = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('shopping_list')
          .get();
      expect(afterSnapshot.docs.isEmpty, isTrue);
    });

    test('updateItem preserves fields not in model (merge: true)', () async {
      final item = ShoppingListItem.create(name: 'Apples', quantity: 1);
      await repository.addItem(item);

      // Manually add a field to Firestore that is not in the model
      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('shopping_list')
          .doc(item.id)
          .set({'extra_field': 'preserve_me'}, SetOptions(merge: true));

      final updatedItem = item.copyWith(quantity: 10);
      await repository.updateItem(updatedItem);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('shopping_list')
          .doc(item.id)
          .get();

      expect(snapshot.data()!['quantity'], 10);
      expect(snapshot.data()!['extra_field'], 'preserve_me');
    });
  });
}
