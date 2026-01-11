import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_service.g.dart';

@Riverpod(keepAlive: true)
FirestoreService firestoreService(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  final profile = ref.watch(userProfileProvider).value;

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return FirestoreService(
    FirebaseFirestore.instance,
    user.uid,
    householdId: profile?.householdId,
  );
}

class FirestoreService {
  final FirebaseFirestore _firestore;
  final String _userId;
  final String? _householdId;
  final Random _random;

  FirestoreService(
    this._firestore,
    this._userId, {
    String? householdId,
    Random? random,
  }) : _householdId = householdId,
       _random = random ?? Random.secure();

  String get _activeHouseholdId => _householdId ?? _userId;

  CollectionReference<Map<String, dynamic>> get _inventoryCollection {
    // Shared inventory: households/{householdId}/inventory
    // Personal inventory: households/{userId}/inventory
    return _firestore
        .collection(householdsCollection)
        .doc(_activeHouseholdId)
        .collection(inventoryCollection);
  }

  Future<List<FridgeItem>> getItems() async {
    final snapshot = await _inventoryCollection.get();
    return snapshot.docs.map((doc) => FridgeItem.fromJson(doc.data())).toList();
  }

  Stream<List<FridgeItem>> watchItems() {
    return _inventoryCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FridgeItem.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> addItem(FridgeItem item) async {
    await _inventoryCollection.doc(item.id).set(item.toJson());
  }

  Future<void> addItemsBatch(List<FridgeItem> items) async {
    final batch = _firestore.batch();
    for (final item in items) {
      batch.set(_inventoryCollection.doc(item.id), item.toJson());
    }
    await batch.commit();
  }

  Future<void> updateItem(FridgeItem item) async {
    await _inventoryCollection.doc(item.id).update(item.toJson());
  }

  Future<void> deleteItem(String id) async {
    await _inventoryCollection.doc(id).delete();
  }

  Future<void> deleteAllItems() async {
    final batch = _firestore.batch();
    final snapshot = await _inventoryCollection.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

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
      'hostUid': _userId,
      'expiresAt': Timestamp.fromDate(expiresAt),
    });

    return code;
  }

  Future<void> joinHousehold(String code) async {
    final doc = await _firestore.collection(invitesCollection).doc(code).get();
    if (!doc.exists) {
      throw Exception('Invalid Code');
    }

    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (!DateTime.now().isBefore(expiresAt)) {
      throw Exception('Code Expired');
    }

    final hostUid = data['hostUid'] as String;
    if (hostUid == _userId) {
      throw Exception('Cannot Join Own Household');
    }

    await _firestore.collection(usersCollection).doc(_userId).update({
      'householdId': hostUid,
    });
  }

  Future<void> removeMember(String uid) async {
    // Only remove if it's actually a guest (leaving hostUid null for guests resets them)
    await _firestore.collection(usersCollection).doc(uid).update({
      'householdId': FieldValue.delete(),
    });
  }

  Future<void> leaveHousehold() async {
    await _firestore.collection(usersCollection).doc(_userId).update({
      'householdId': FieldValue.delete(),
    });
  }

  String _generateRandom6Digit() {
    final randomValue = _random.nextInt(1000000);
    return randomValue.toString().padLeft(6, '0');
  }
}
