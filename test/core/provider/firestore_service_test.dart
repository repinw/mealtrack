import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;
  const userId = 'user-123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirestoreService(fakeFirestore, userId);
  });

  group('FirestoreService', () {
    group('Invites', () {
      test('generateInviteCode creates document with expiresAt', () async {
        final code = await firestoreService.generateInviteCode();

        final snapshot = await fakeFirestore
            .collection(invitesCollection)
            .doc(code)
            .get();

        expect(snapshot.exists, isTrue);
        expect(snapshot.data()!['hostUid'], userId);
        expect(snapshot.data()!.containsKey('expiresAt'), isTrue);
      });
    });

    group('Households', () {
      test('joinHousehold success updates user householdId', () async {
        // Setup Invite
        const inviteCode = '123456';
        const hostId = 'host-user';
        final expiresAt = DateTime.now().add(const Duration(hours: 1));

        await fakeFirestore.collection(invitesCollection).doc(inviteCode).set({
          'hostUid': hostId,
          'expiresAt': Timestamp.fromDate(expiresAt),
        });

        // Setup User
        await fakeFirestore.collection(usersCollection).doc(userId).set({
          'uid': userId,
        });

        // Action
        await firestoreService.joinHousehold(inviteCode);

        // Verify
        final userDoc = await fakeFirestore
            .collection(usersCollection)
            .doc(userId)
            .get();
        expect(userDoc.data()!['householdId'], hostId);
      });

      test('joinHousehold fails with Invalid Code', () async {
        expect(
          () => firestoreService.joinHousehold('invalid-code'),
          throwsA(predicate((e) => e.toString().contains('Invalid Code'))),
        );
      });

      test('joinHousehold fails with Expired Code', () async {
        const inviteCode = 'expired-code';
        const hostId = 'host-user';
        final expiresAt = DateTime.now().subtract(
          const Duration(hours: 1),
        ); // Past

        await fakeFirestore.collection(invitesCollection).doc(inviteCode).set({
          'hostUid': hostId,
          'expiresAt': Timestamp.fromDate(expiresAt),
        });

        expect(
          () => firestoreService.joinHousehold(inviteCode),
          throwsA(predicate((e) => e.toString().contains('Code Expired'))),
        );
      });

      test('joinHousehold fails when joining Own Household', () async {
        const inviteCode = 'my-own-code';
        final expiresAt = DateTime.now().add(const Duration(hours: 1));

        // Invite where host is ME
        await fakeFirestore.collection(invitesCollection).doc(inviteCode).set({
          'hostUid': userId,
          'expiresAt': Timestamp.fromDate(expiresAt),
        });

        expect(
          () => firestoreService.joinHousehold(inviteCode),
          throwsA(
            predicate(
              (e) => e.toString().contains('Cannot Join Own Household'),
            ),
          ),
        );
      });

      test('leaveHousehold removes householdId from user', () async {
        // Setup User in a household
        await fakeFirestore.collection(usersCollection).doc(userId).set({
          'uid': userId,
          'householdId': 'some-host-id',
        });

        // Action
        await firestoreService.leaveHousehold();

        // Verify
        final userDoc = await fakeFirestore
            .collection(usersCollection)
            .doc(userId)
            .get();
        expect(userDoc.data()!.containsKey('householdId'), isFalse);
      });

      test('removeMember removes householdId from target user', () async {
        const targetUserId = 'target-user';

        // Setup Target User
        await fakeFirestore.collection(usersCollection).doc(targetUserId).set({
          'uid': targetUserId,
          'householdId': userId, // In my household
        });

        // Action
        await firestoreService.removeMember(targetUserId);

        // Verify
        final userDoc = await fakeFirestore
            .collection(usersCollection)
            .doc(targetUserId)
            .get();
        expect(userDoc.data()!.containsKey('householdId'), isFalse);
      });
    });

    group('Inventory', () {
      test('addItem adds item to inventory collection', () async {
        final item = FridgeItem.create(
          name: 'Milk',
          storeName: 'Shop',
          quantity: 1,
          now: () => DateTime.now(),
        );

        await firestoreService.addItem(item);

        final items = await firestoreService.getItems();
        expect(items.length, 1);
        expect(items.first.name, 'Milk');
      });

      test('deleteItem removes item', () async {
        final item = FridgeItem.create(
          name: 'Bread',
          storeName: 'Shop',
          quantity: 1,
          now: () => DateTime.now(),
        );

        await firestoreService.addItem(item);

        // Verify added
        var items = await firestoreService.getItems();
        expect(items.length, 1);

        // Delete
        await firestoreService.deleteItem(item.id);

        // Verify removed
        items = await firestoreService.getItems();
        expect(items, isEmpty);
      });
    });
  });
}
