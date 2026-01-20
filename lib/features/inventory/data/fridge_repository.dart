import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/core/utils/firestore_utils.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fridge_repository.g.dart';

@riverpod
FridgeRepository fridgeRepository(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  final profile = ref.watch(userProfileProvider).value;
  final firestore = ref.watch(firebaseFirestoreProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  final targetUid = profile?.householdId ?? user.uid;
  final collection = firestore
      .collection(usersCollection)
      .doc(targetUid)
      .collection(inventoryCollection);

  return FridgeRepository(collection);
}

class FridgeRepository {
  final CollectionReference<Map<String, dynamic>> _collection;
  final FirebaseFirestore _firestore;

  FridgeRepository(this._collection) : _firestore = _collection.firestore;

  Future<List<FridgeItem>> getItems() async {
    try {
      final snapshot = await _collection.get();
      return snapshot.docs
          .map((doc) => FridgeItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<FridgeItem>> watchItems() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FridgeItem.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> addItems(List<FridgeItem> items) async {
    try {
      await FirestoreUtils.processInBatches(_firestore, items, (batch, item) {
        batch.set(_collection.doc(item.id), item.toJson());
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItem(FridgeItem item) async {
    try {
      await _collection.doc(item.id).update(item.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItemsBatch(List<FridgeItem> items) async {
    try {
      await FirestoreUtils.processInBatches(_firestore, items, (batch, item) {
        batch.update(_collection.doc(item.id), item.toJson());
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(FridgeItem item, int delta) async {
    try {
      await _collection
          .doc(item.id)
          .update(item.adjustQuantity(delta).toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllItems() async {
    try {
      final snapshot = await _collection.get();
      final items = snapshot.docs;
      await FirestoreUtils.processInBatches(_firestore, items, (batch, doc) {
        batch.delete(doc.reference);
      });
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

  Future<List<FridgeItem>> getAvailableItems() async {
    try {
      final items = await getItems();
      return items.where((item) => item.quantity > 0).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MapEntry<String, List<FridgeItem>>>> getGroupedItems() async {
    try {
      final items = await getItems();
      final groupedMap = <String, List<FridgeItem>>{};

      for (final item in items) {
        final key = item.receiptId ?? '';
        if (!groupedMap.containsKey(key)) {
          groupedMap[key] = [];
        }
        groupedMap[key]!.add(item);
      }

      return groupedMap.entries.toList();
    } catch (e) {
      rethrow;
    }
  }
}
