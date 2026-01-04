import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late FirestoreService firestoreService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    firestoreService = FirestoreService(fakeFirestore, 'test_user_id');
  });

  group('FirestoreService', () {
    test('addItem adds item to firestore', () async {
      await mockAuth.signInAnonymously();
      final item = FridgeItem(
        id: '1',
        name: 'Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );

      await firestoreService.addItem(item);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('1')
          .get();

      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['name'], 'Apple');
    });

    test('addItemsBatch adds multiple items using batch', () async {
      await mockAuth.signInAnonymously();
      final item1 = FridgeItem(
        id: '1',
        name: 'Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );
      final item2 = FridgeItem(
        id: '2',
        name: 'Banana',
        quantity: 2,
        entryDate: DateTime(2023, 1, 2),
        storeName: 'Test Store',
      );

      await firestoreService.addItemsBatch([item1, item2]);

      final snapshot1 = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('1')
          .get();
      final snapshot2 = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('2')
          .get();

      expect(snapshot1.exists, isTrue);
      expect(snapshot1.data()!['name'], 'Apple');
      expect(snapshot2.exists, isTrue);
      expect(snapshot2.data()!['name'], 'Banana');
    });

    test('getItems returns list of items', () async {
      await mockAuth.signInAnonymously();
      final item1 = FridgeItem(
        id: '1',
        name: 'Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );
      final item2 = FridgeItem(
        id: '2',
        name: 'Banana',
        quantity: 2,
        entryDate: DateTime(2023, 1, 2),
        storeName: 'Test Store',
      );

      await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('1')
          .set(item1.toJson());
      await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('2')
          .set(item2.toJson());

      final items = await firestoreService.getItems();

      expect(items.length, 2);
      expect(items.any((i) => i.id == '1'), isTrue);
      expect(items.any((i) => i.id == '2'), isTrue);
    });

    test('updateItem updates existing item', () async {
      await mockAuth.signInAnonymously();
      final item = FridgeItem(
        id: '1',
        name: 'Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );

      await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('1')
          .set(item.toJson());

      final updatedItem = item.copyWith(name: 'Green Apple', quantity: 5);

      await firestoreService.updateItem(updatedItem);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('1')
          .get();

      expect(snapshot.data()!['name'], 'Green Apple');
      expect(snapshot.data()!['quantity'], 5);
    });

    test('deleteItem removes item', () async {
      await mockAuth.signInAnonymously();
      final item = FridgeItem(
        id: '1',
        name: 'Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );

      await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('1')
          .set(item.toJson());

      await firestoreService.deleteItem('1');

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('1')
          .get();

      expect(snapshot.exists, isFalse);
    });

    test('deleteAllItems removes all items', () async {
      await mockAuth.signInAnonymously();
      final item1 = FridgeItem(
        id: '1',
        name: 'Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );
      final item2 = FridgeItem(
        id: '2',
        name: 'Banana',
        quantity: 2,
        entryDate: DateTime(2023, 1, 2),
        storeName: 'Test Store',
      );

      await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('1')
          .set(item1.toJson());
      await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .doc('2')
          .set(item2.toJson());

      await firestoreService.deleteAllItems();

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('inventory')
          .get();

      expect(snapshot.docs.isEmpty, isTrue);
    });
  });
}
