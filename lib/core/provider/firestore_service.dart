import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_service.g.dart';

@Riverpod(keepAlive: true)
FirestoreService firestoreService(Ref ref) {
  return FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);
}

class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService(this._firestore, this._auth);

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _inventoryCollection {
    return _firestore.collection('users').doc(_userId).collection('inventory');
  }

  Future<List<FridgeItem>> getItems() async {
    final snapshot = await _inventoryCollection.get();
    return snapshot.docs.map((doc) => FridgeItem.fromJson(doc.data())).toList();
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

  /// Upserts all provided items using merge semantics to avoid race conditions.
  ///
  /// Note: This method does NOT delete orphaned documents that are not in [items].
  /// If deletion is required, use [deleteItem] explicitly or implement soft deletes.
  Future<void> replaceAllItems(List<FridgeItem> items) async {
    final batch = _firestore.batch();
    for (var item in items) {
      batch.set(
        _inventoryCollection.doc(item.id),
        item.toJson(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
