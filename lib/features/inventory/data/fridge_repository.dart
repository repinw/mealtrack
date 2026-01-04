import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fridge_repository.g.dart';

@riverpod
FridgeRepository fridgeRepository(Ref ref) {
  return FridgeRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
}

class FridgeRepository {
  final FirestoreService _firestoreService;

  FridgeRepository({required FirestoreService firestoreService})
    : _firestoreService = firestoreService;

  Future<List<FridgeItem>> getItems() async {
    try {
      return await _firestoreService.getItems();
    } catch (e) {
      debugPrint('Error loading items from repository: $e');
      rethrow;
    }
  }

  Future<void> addItems(List<FridgeItem> items) async {
    try {
      await _firestoreService.addItemsBatch(items);
    } catch (e) {
      debugPrint('Error adding items in repository: $e');
      rethrow;
    }
  }

  Future<void> updateItem(FridgeItem item) async {
    try {
      await _firestoreService.updateItem(item);
    } catch (e) {
      debugPrint('Error updating item in repository: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(FridgeItem item, int delta) async {
    try {
      await _firestoreService.updateItem(item.adjustQuantity(delta));
    } catch (e) {
      debugPrint('Error updating quantity in repository: $e');
      rethrow;
    }
  }

  Future<void> deleteAllItems() async {
    try {
      await _firestoreService.deleteAllItems();
    } catch (e) {
      debugPrint('Error deleting all items in repository: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firestoreService.deleteItem(id);
    } catch (e) {
      debugPrint('Error deleting item in repository: $e');
      rethrow;
    }
  }

  Future<List<FridgeItem>> getAvailableItems() async {
    try {
      final items = await getItems();
      return items.where((item) => item.quantity > 0).toList();
    } catch (e) {
      debugPrint('Error getting available items in repository: $e');
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
      debugPrint('Error getting grouped items in repository: $e');
      rethrow;
    }
  }
}
