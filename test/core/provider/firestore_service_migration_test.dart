// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  const oldUserId = 'old_user_id';
  const newUserId = 'new_user_id';

  group('migrateGuestData (Happy Path - FakeFirestore)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService firestoreService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(fakeFirestore, newUserId);
    });

    test('migrates documents correctly', () async {
      // Setup: Create data for old user
      final oldInventory = fakeFirestore
          .collection('users')
          .doc(oldUserId)
          .collection('inventory');

      await oldInventory.doc('1').set({'name': 'Item 1'});
      await oldInventory.doc('2').set({'name': 'Item 2'});
      await oldInventory.doc('3').set({'name': 'Item 3'});

      // Act
      await firestoreService.migrateGuestData(oldUserId, newUserId);

      // Assert: Old data gone
      final oldSnap = await oldInventory.get();
      expect(oldSnap.docs.isEmpty, isTrue);

      // Assert: New data present
      final newInventory = fakeFirestore
          .collection('users')
          .doc(newUserId)
          .collection('inventory');
      final newSnap = await newInventory.get();
      expect(newSnap.docs.length, 3);
      expect(
        newSnap.docs.any((d) => d.id == '1' && d['name'] == 'Item 1'),
        isTrue,
      );
      expect(
        newSnap.docs.any((d) => d.id == '2' && d['name'] == 'Item 2'),
        isTrue,
      );
      expect(
        newSnap.docs.any((d) => d.id == '3' && d['name'] == 'Item 3'),
        isTrue,
      );
    });

    test('does nothing if empty', () async {
      await firestoreService.migrateGuestData(oldUserId, newUserId);

      final newInventory = fakeFirestore
          .collection('users')
          .doc(newUserId)
          .collection('inventory');
      final snap = await newInventory.get();
      expect(snap.docs.isEmpty, isTrue);
    });
  });

  group('migrateGuestData (Batch Limit - Mocktail)', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockUsersCollection;
    late MockDocumentReference mockOldUserDoc;
    late MockCollectionReference mockOldInventoryCollection;
    late MockDocumentReference mockNewUserDoc;
    late MockCollectionReference mockNewInventoryCollection;
    late MockWriteBatch mockBatch;
    late FirestoreService firestoreService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockUsersCollection = MockCollectionReference();
      mockOldUserDoc = MockDocumentReference();
      mockOldInventoryCollection = MockCollectionReference();
      mockNewUserDoc = MockDocumentReference();
      mockNewInventoryCollection = MockCollectionReference();
      mockBatch = MockWriteBatch();

      when(
        () => mockFirestore.collection('users'),
      ).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(oldUserId)).thenReturn(mockOldUserDoc);
      when(
        () => mockOldUserDoc.collection('inventory'),
      ).thenReturn(mockOldInventoryCollection);
      when(() => mockUsersCollection.doc(newUserId)).thenReturn(mockNewUserDoc);
      when(
        () => mockNewUserDoc.collection('inventory'),
      ).thenReturn(mockNewInventoryCollection);
      when(() => mockFirestore.batch()).thenReturn(mockBatch);
      when(() => mockBatch.commit()).thenAnswer((_) async {});

      // Register fallbacks
      registerFallbackValue(MockDocumentReference());
      registerFallbackValue(<String, dynamic>{});

      firestoreService = FirestoreService(mockFirestore, newUserId);
    });

    MockQueryDocumentSnapshot createMockDoc(
      String id,
      Map<String, dynamic> data,
    ) {
      final doc = MockQueryDocumentSnapshot();
      final ref = MockDocumentReference();
      when(() => doc.id).thenReturn(id);
      when(() => doc.data()).thenReturn(data);
      when(() => doc.reference).thenReturn(ref);
      return doc;
    }

    test('handles 300 documents via chunking (2 batches)', () async {
      final docs = List.generate(
        300,
        (index) => createMockDoc('$index', {'val': index}),
      );
      final snapshot = MockQuerySnapshot();
      when(() => snapshot.docs).thenReturn(docs);
      when(
        () => mockOldInventoryCollection.get(),
      ).thenAnswer((_) async => snapshot);

      // Use any() for new doc ref to avoid strict matching issues
      when(
        () => mockNewInventoryCollection.doc(any()),
      ).thenReturn(MockDocumentReference());

      await firestoreService.migrateGuestData(oldUserId, newUserId);

      // Verify 2 batches committed (200 + 100)
      verify(() => mockFirestore.batch()).called(2);
      verify(() => mockBatch.commit()).called(2);
    });
  });
}
