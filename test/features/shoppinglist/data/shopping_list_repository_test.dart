import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

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
      expect(snapshot.data()!.containsKey('createdAt'), isTrue);
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

    test('watchItems returns items ordered by createdAt (insertion order)', () async {
      final itemA = ShoppingListItem.create(name: 'Bananas');
      final itemB = ShoppingListItem.create(name: 'Apples');
      final itemC = ShoppingListItem.create(name: 'Cherries');

      await repository.addItem(itemA);
      await repository.addItem(itemB);
      await repository.addItem(itemC);

      final stream = repository.watchItems();
      final firstResult = await stream.first;

      expect(firstResult.length, 3);
      expect(firstResult[0].name, 'Bananas');
      expect(firstResult[1].name, 'Apples');
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

    test('Happy Path (Merge): Merges item with same name and brand', () async {
      // 1. Existing item
      const name = 'Milch';
      const brand = 'Ja!';
      await repository.addOrMergeItem(
        name: name,
        brand: brand,
        quantity: 1,
        unitPrice: 1.0,
      );

      // 2. Add same item again
      await repository.addOrMergeItem(
        name: name,
        brand: brand,
        quantity: 2,
        unitPrice:
            1.0, // Unit price might update, but here we focus on quantity merge
      );

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();

      expect(
        snapshot.docs.length,
        1,
        reason: 'Should have merged into one document',
      );
      final data = snapshot.docs.first.data();
      expect(data['name'], name);
      expect(data['brand'], brand);
      expect(data['quantity'], 3, reason: '1 + 2 = 3');
    });

    test('Happy Path (New): Creates new item with normalizedName', () async {
      const name = 'Neues Produkt';
      await repository.addOrMergeItem(
        name: name,
        brand: 'Marke',
        quantity: 1,
        unitPrice: 2.50,
      );

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();

      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['name'], name);
      expect(data['normalizedName'], 'neues produkt');
    });

    test(
      'Edge Case (Brand Null vs. Empty): Treats null and empty string as different brands',
      () async {
        // 1. Add "Brot" with brand: null
        await repository.addOrMergeItem(
          name: 'Brot',
          brand: null,
          quantity: 1,
          unitPrice: 1.0,
        );

        // 2. Add "Brot" with brand: "Bäcker"
        await repository.addOrMergeItem(
          name: 'Brot',
          brand: 'Bäcker',
          quantity: 1,
          unitPrice: 1.5,
        );

        final snapshot = await fakeFirestore
            .collection(usersCollection)
            .doc(testUid)
            .collection(shoppingListCollection)
            .get();

        expect(
          snapshot.docs.length,
          2,
          reason: 'Null brand and "Bäcker" should remain separate',
        );

        final docNullBrand = snapshot.docs.firstWhere(
          (d) => d.data()['brand'] == null,
        );
        final docBakeryBrand = snapshot.docs.firstWhere(
          (d) => d.data()['brand'] == 'Bäcker',
        );

        expect(docNullBrand.exists, isTrue);
        expect(docBakeryBrand.exists, isTrue);
      },
    );

    test('addOrMergeItem keeps old unitPrice when new unitPrice is null', () async {
      await repository.addOrMergeItem(
        name: 'Milk',
        brand: 'Farm',
        quantity: 1,
        unitPrice: 2.0,
      );
      await repository.addOrMergeItem(
        name: 'Milk',
        brand: 'Farm',
        quantity: 1,
        unitPrice: null,
      );

      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc(testUid)
          .collection(shoppingListCollection)
          .get();

      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['quantity'], 2);
      expect(data['unitPrice'], 2.0);
    });
  });

  group('shoppingListRepositoryProvider', () {
    late FakeFirebaseFirestore firestore;
    late _MockUser user;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      user = _MockUser();
      when(() => user.uid).thenReturn('user-id');
    });

    test('uses householdId when profile has one', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWith((ref) => firestore),
          authStateChangesProvider.overrideWith((ref) => Stream.value(user)),
          userProfileProvider.overrideWith(
            (ref) => Stream.value(const UserProfile(uid: 'user-id', householdId: 'hh')),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.listen(authStateChangesProvider, (_, _) {});
      container.listen(userProfileProvider, (_, _) {});
      await container.read(authStateChangesProvider.future);
      await container.read(userProfileProvider.future);

      final repo = container.read(shoppingListRepositoryProvider);
      expect(repo, isA<ShoppingListRepository>());
    });

    test('throws when user is null', () {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWith((ref) => firestore),
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
          userProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      container.listen(authStateChangesProvider, (_, _) {});

      expect(
        () => container.read(shoppingListRepositoryProvider),
        throwsA(isA<Exception>()),
      );
    });
  });
}
