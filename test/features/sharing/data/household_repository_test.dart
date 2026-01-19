import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/features/sharing/data/household_repository.dart';
import 'package:mealtrack/features/sharing/domain/sharing_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late HouseholdRepository repository;
  const userId = 'user-123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = HouseholdRepository(fakeFirestore, userId);
  });

  group('HouseholdRepository', () {
    test('generateInviteCode creates document with expiresAt', () async {
      final code = await repository.generateInviteCode();

      final snapshot = await fakeFirestore
          .collection(invitesCollection)
          .doc(code)
          .get();

      expect(snapshot.exists, isTrue);
      expect(code.length, 6);
      expect(snapshot.data()!['hostUid'], userId);
      expect(snapshot.data()!.containsKey('expiresAt'), isTrue);
    });

    test('joinHousehold success updates user householdId', () async {
      const inviteCode = '123456';
      const hostId = 'host-user';
      final expiresAt = DateTime.now().add(const Duration(hours: 1));

      await fakeFirestore.collection(invitesCollection).doc(inviteCode).set({
        'hostUid': hostId,
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      await fakeFirestore.collection(usersCollection).doc(userId).set({
        'uid': userId,
      });

      await repository.joinHousehold(inviteCode);

      final userDoc = await fakeFirestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      expect(userDoc.data()!['householdId'], hostId);
    });

    test('joinHousehold fails with Invalid Code', () async {
      expect(
        () => repository.joinHousehold('invalid-code'),
        throwsA(isA<InvalidInviteCodeException>()),
      );
    });

    test('joinHousehold fails with Expired Code', () async {
      const inviteCode = 'expired-code';
      const hostId = 'host-user';
      final expiresAt = DateTime.now().subtract(const Duration(hours: 1));

      await fakeFirestore.collection(invitesCollection).doc(inviteCode).set({
        'hostUid': hostId,
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      expect(
        () => repository.joinHousehold(inviteCode),
        throwsA(isA<InviteExpiredException>()),
      );
    });

    test('joinHousehold fails when joining Own Household', () async {
      const inviteCode = 'my-own-code';
      final expiresAt = DateTime.now().add(const Duration(hours: 1));

      await fakeFirestore.collection(invitesCollection).doc(inviteCode).set({
        'hostUid': userId,
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      expect(
        () => repository.joinHousehold(inviteCode),
        throwsA(isA<SelfJoinException>()),
      );
    });

    test('leaveHousehold removes householdId from user', () async {
      await fakeFirestore.collection(usersCollection).doc(userId).set({
        'uid': userId,
        'householdId': 'some-host-id',
      });

      await repository.leaveHousehold();

      final userDoc = await fakeFirestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      expect(userDoc.data()!.containsKey('householdId'), isFalse);
    });

    test('removeMember removes householdId from target user', () async {
      const targetUserId = 'target-user';

      await fakeFirestore.collection(usersCollection).doc(targetUserId).set({
        'uid': targetUserId,
        'householdId': userId,
      });

      await repository.removeMember(targetUserId);

      final userDoc = await fakeFirestore
          .collection(usersCollection)
          .doc(targetUserId)
          .get();
      expect(userDoc.data()!.containsKey('householdId'), isFalse);
    });
  });
}
