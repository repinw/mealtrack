import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late FakeFirebaseFirestore fakeFirestore;
  const userId = 'user-A';
  const householdId = 'household-B';

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    fakeFirestore = FakeFirebaseFirestore();

    when(() => mockUser.uid).thenReturn(userId);
    when(() => mockUser.email).thenReturn('userA@example.com');
    when(() => mockUser.displayName).thenReturn('User A');
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(
      () => mockFirebaseAuth.authStateChanges(),
    ).thenAnswer((_) => Stream.value(mockUser));
  });

  test(
    'Integration: Inventory Provider switches from Personal to Shared on Join',
    () async {
      // 1. Setup Personal Data
      final personalItem = FridgeItem.create(
        name: 'Personal Apple',
        storeName: 'Shop',
        quantity: 1,
        now: () => DateTime.now(),
      );
      await fakeFirestore
          .collection(usersCollection)
          .doc(userId)
          .collection(inventoryCollection)
          .doc(personalItem.id)
          .set(personalItem.toJson());

      // 2. Setup Shared Data
      final sharedItem = FridgeItem.create(
        name: 'Shared Banana',
        storeName: 'Market',
        quantity: 5,
        now: () => DateTime.now(),
      );
      await fakeFirestore
          .collection(householdsCollection)
          .doc(householdId)
          .collection(inventoryCollection)
          .doc(sharedItem.id)
          .set(sharedItem.toJson());

      // 3. Pre-create User Profile
      await fakeFirestore.collection(usersCollection).doc(userId).set({
        'uid': userId,
        'email': 'userA@example.com',
        'displayName': 'User A',
        'isAnonymous': false,
      });

      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(mockUser),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Track states
      final capturedItems = <List<FridgeItem>>[];
      final capturedErrors = <Object?>[];

      container.listen<AsyncValue<List<FridgeItem>>>(fridgeItemsProvider, (
        prev,
        next,
      ) {
        if (next is AsyncData<List<FridgeItem>>) {
          capturedItems.add(next.value);
        } else if (next is AsyncError) {
          capturedErrors.add(next.error);
        }
      }, fireImmediately: true);

      // 4. Wait for initial (Personal) state
      await poll(
        () =>
            capturedItems.isNotEmpty &&
            capturedItems.any(
              (list) => list.any((i) => i.name == 'Personal Apple'),
            ),
        timeout: const Duration(seconds: 10),
      );

      expect(capturedItems.last.any((i) => i.name == 'Personal Apple'), isTrue);
      expect(capturedItems.last.any((i) => i.name == 'Shared Banana'), isFalse);

      // 5. Join Household
      await fakeFirestore.collection(invitesCollection).doc('CODE123').set({
        'hostUid': householdId,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 1)),
        ),
      });

      final service = container.read(firestoreServiceProvider);
      await service.joinHousehold('CODE123');

      // 6. Verify Switch
      await poll(
        () =>
            capturedItems.isNotEmpty &&
            capturedItems.last.any((i) => i.name == 'Shared Banana'),
        timeout: const Duration(seconds: 10),
      );

      expect(capturedItems.last.any((i) => i.name == 'Shared Banana'), isTrue);
      expect(
        capturedItems.last.any((i) => i.name == 'Personal Apple'),
        isFalse,
      );
    },
  );
}

Future<void> poll(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final start = DateTime.now();
  while (!condition()) {
    if (DateTime.now().difference(start) > timeout) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
