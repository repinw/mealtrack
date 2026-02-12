import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/utils/firestore_utils.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/core/config/app_config.dart';

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
  final FirebaseFirestore _firestore;
  final String _uid;

  ShoppingListRepository(this._firestore, this._uid);

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection(usersCollection)
      .doc(_uid)
      .collection(shoppingListCollection);

  Future<void> addItem(ShoppingListItem item) async {
    try {
      final json = item.toJson();
      json['normalizedName'] = item.name.toLowerCase();
      json['createdAt'] = FieldValue.serverTimestamp();
      await _collection.doc(item.id).set(json);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addOrMergeItem({
    required String name,
    required String? brand,
    required int quantity,
    required double? unitPrice,
    String? category,
  }) async {
    try {
      final normalizedName = name.toLowerCase();

      await _firestore.runTransaction((transaction) async {
        final querySnapshot = await _collection
            .where('normalizedName', isEqualTo: normalizedName)
            .where('brand', isEqualTo: brand)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final existingItem = ShoppingListItem.fromJson(doc.data());
          final updatedItem = existingItem.copyWith(
            quantity: existingItem.quantity + quantity,
            unitPrice: unitPrice ?? existingItem.unitPrice,
          );
          final json = updatedItem.toJson();
          json['normalizedName'] = normalizedName; // Ensure preserved/updated
          transaction.set(doc.reference, json);
        } else {
          final newItem = ShoppingListItem.create(
            name: name,
            brand: brand,
            quantity: quantity,
            unitPrice: unitPrice,
            category: category,
          );
          final json = newItem.toJson();
          json['normalizedName'] = normalizedName;
          json['createdAt'] = FieldValue.serverTimestamp();
          transaction.set(_collection.doc(newItem.id), json);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItem(ShoppingListItem item) async {
    try {
      final json = item.toJson();
      json['normalizedName'] = item.name.toLowerCase();
      await _collection.doc(item.id).set(json, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
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
      rethrow;
    }
  }

  Stream<List<ShoppingListItem>> watchItems() => _collection
      .orderBy('createdAt')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => ShoppingListItem.fromJson(doc.data()))
            .toList(),
      );
}
