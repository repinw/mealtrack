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
    firestoreService = FirestoreService(fakeFirestore, mockAuth);
  });

  group('FirestoreService', () {
    test('throws exception when user is not authenticated', () {
      expect(() => firestoreService.getItems(), throwsException);
    });

    test('addItem adds item to firestore', () async {
      await mockAuth.signInAnonymously();
      final user = mockAuth.currentUser!;
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
          .doc(user.uid)
          .collection('inventory')
          .doc('1')
          .get();

      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['name'], 'Apple');
    });

    test('getItems returns list of items', () async {
      await mockAuth.signInAnonymously();
      final user = mockAuth.currentUser!;
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
          .doc(user.uid)
          .collection('inventory')
          .doc('1')
          .set(item1.toJson());
      await fakeFirestore
          .collection('users')
          .doc(user.uid)
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
      final user = mockAuth.currentUser!;
      final item = FridgeItem(
        id: '1',
        name: 'Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );

      await fakeFirestore
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .doc('1')
          .set(item.toJson());

      final updatedItem = item.copyWith(name: 'Green Apple', quantity: 5);

      await firestoreService.updateItem(updatedItem);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .doc('1')
          .get();

      expect(snapshot.data()!['name'], 'Green Apple');
      expect(snapshot.data()!['quantity'], 5);
    });

    test('deleteItem removes item', () async {
      await mockAuth.signInAnonymously();
      final user = mockAuth.currentUser!;
      final item = FridgeItem(
        id: '1',
        name: 'Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );

      await fakeFirestore
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .doc('1')
          .set(item.toJson());

      await firestoreService.deleteItem('1');

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .doc('1')
          .get();

      expect(snapshot.exists, isFalse);
    });

    test('deleteAllItems removes all items', () async {
      await mockAuth.signInAnonymously();
      final user = mockAuth.currentUser!;
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
          .doc(user.uid)
          .collection('inventory')
          .doc('1')
          .set(item1.toJson());
      await fakeFirestore
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .doc('2')
          .set(item2.toJson());

      await firestoreService.deleteAllItems();

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .get();

      expect(snapshot.docs.isEmpty, isTrue);
    });

    test('replaceAllItems replaces all items', () async {
      await mockAuth.signInAnonymously();
      final user = mockAuth.currentUser!;
      final oldItem = FridgeItem(
        id: '1',
        name: 'Old Apple',
        quantity: 1,
        entryDate: DateTime(2023, 1, 1),
        storeName: 'Test Store',
      );

      await fakeFirestore
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .doc('1')
          .set(oldItem.toJson());

      final newItem1 = FridgeItem(
        id: '2',
        name: 'New Banana',
        quantity: 2,
        entryDate: DateTime(2023, 1, 2),
        storeName: 'Test Store',
      );
      final newItem2 = FridgeItem(
        id: '3',
        name: 'New Orange',
        quantity: 3,
        entryDate: DateTime(2023, 1, 3),
        storeName: 'Test Store',
      );

      await firestoreService.replaceAllItems([newItem1, newItem2]);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .get();

      expect(snapshot.docs.length, 2);
      expect(snapshot.docs.any((d) => d.id == '1'), isFalse);
      expect(snapshot.docs.any((d) => d.id == '2'), isTrue);
      expect(snapshot.docs.any((d) => d.id == '3'), isTrue);
    });
  });
}
