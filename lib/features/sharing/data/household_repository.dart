import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/sharing/domain/sharing_exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'household_repository.g.dart';

@riverpod
HouseholdRepository householdRepository(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  final firestore = ref.watch(firebaseFirestoreProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return HouseholdRepository(firestore, user.uid);
}

class HouseholdRepository {
  static const String _fieldHouseholdId = 'householdId';
  static const String _fieldHostUid = 'hostUid';
  static const String _fieldExpiresAt = 'expiresAt';

  final FirebaseFirestore _firestore;
  final String _userId;
  final Random _random;

  HouseholdRepository(this._firestore, this._userId, {Random? random})
    : _random = random ?? Random.secure();

  Future<String> generateInviteCode() async {
    String code = '';
    bool exists = true;
    int attempts = 0;

    while (exists && attempts < 3) {
      code = _generateRandom6Digit();
      final doc = await _firestore
          .collection(invitesCollection)
          .doc(code)
          .get();
      exists = doc.exists;
      attempts++;
    }

    final expiresAt = DateTime.now().add(const Duration(days: 1));

    await _firestore.collection(invitesCollection).doc(code).set({
      _fieldHostUid: _userId,
      _fieldExpiresAt: Timestamp.fromDate(expiresAt),
    });

    return code;
  }

  Future<void> joinHousehold(String code) async {
    final doc = await _firestore.collection(invitesCollection).doc(code).get();
    if (!doc.exists) {
      throw InvalidInviteCodeException();
    }

    final data = doc.data()!;
    final expiresAt = (data[_fieldExpiresAt] as Timestamp).toDate();
    if (!DateTime.now().isBefore(expiresAt)) {
      throw InviteExpiredException();
    }

    final hostUid = data[_fieldHostUid] as String;
    if (hostUid == _userId) {
      throw SelfJoinException();
    }

    await _firestore.collection(usersCollection).doc(_userId).update({
      _fieldHouseholdId: hostUid,
    });
  }

  Future<void> removeMember(String uid) async {
    await _firestore.collection(usersCollection).doc(uid).update({
      _fieldHouseholdId: FieldValue.delete(),
    });
  }

  Future<void> leaveHousehold() async {
    await _firestore.collection(usersCollection).doc(_userId).update({
      _fieldHouseholdId: FieldValue.delete(),
    });
  }

  String _generateRandom6Digit() {
    final randomValue = _random.nextInt(1000000);
    return randomValue.toString().padLeft(6, '0');
  }
}
