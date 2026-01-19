import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/utils/firestore_utils.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';

part 'shopping_list_repository.g.dart';

@riverpod
ShoppingListRepository shoppingListRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final user = ref.watch(authStateChangesProvider).value;
  final userProfile = ref.watch(userProfileProvider).value;

  if (user == null) {
    throw Exception('User must be logged in to access the shopping list.');
  }

  final targetUid = userProfile?.householdId ?? user.uid;
  return ShoppingListRepository(firestore, targetUid);
}

class ShoppingListRepository {
  static const String _usersCollection = 'users';
  static const String _collectionName = 'shopping_list';

  final FirebaseFirestore _firestore;
  final String _uid;

  ShoppingListRepository(this._firestore, this._uid);

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection(_usersCollection)
      .doc(_uid)
      .collection(_collectionName);

  Future<void> addItem(ShoppingListItem item) async {
    try {
      await _collection.doc(item.id).set(item.toJson());
    } catch (e) {
      debugPrint('Error adding item to shopping list: $e');
      rethrow;
    }
  }

  Future<void> updateItem(ShoppingListItem item) async {
    try {
      await _collection
          .doc(item.id)
          .set(item.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating item in shopping list: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting item from shopping list: $e');
      rethrow;
    }
  }

  Future<void> clearList() async {
    try {
      final snapshot = await _collection.get();
      final docs = snapshot.docs;
      await FirestoreUtils.processInBatches(_firestore, docs, (batch, doc) {
        batch.delete(doc.reference);
      });
    } catch (e) {
      debugPrint('Error clearing shopping list: $e');
      rethrow;
    }
  }

  Stream<List<ShoppingListItem>> watchItems() => _collection
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => ShoppingListItem.fromJson(doc.data()))
            .toList(),
      );
}
