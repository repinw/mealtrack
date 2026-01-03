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

  Future<void> replaceAllItems(List<FridgeItem> items) async {
    final batch = _firestore.batch();
    final snapshot = await _inventoryCollection.get();
    final newIds = items.map((item) => item.id).toSet();

    for (var doc in snapshot.docs) {
      if (!newIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (var item in items) {
      batch.set(_inventoryCollection.doc(item.id), item.toJson());
    }

    await batch.commit();
  }
}
