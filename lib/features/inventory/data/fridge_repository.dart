import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fridge_repository.g.dart';

@riverpod
FridgeRepository fridgeRepository(Ref ref) {
  return FridgeRepository(
    localStorageService: ref.watch(localStorageServiceProvider),
  );
}

/// Repository for managing fridge items.
/// Acts as the single source of truth for inventory data.
class FridgeRepository {
  final LocalStorageService _localStorageService;

  FridgeRepository({required LocalStorageService localStorageService})
    : _localStorageService = localStorageService;

  /// Retrieves all fridge items from storage.
  Future<List<FridgeItem>> getItems() async {
    try {
      return await _localStorageService.loadItems();
    } catch (e) {
      debugPrint('Error loading items from repository: $e');
      rethrow;
    }
  }

  /// Saves the provided list of items to storage.
  Future<void> saveItems(List<FridgeItem> items) async {
    try {
      await _localStorageService.saveItems(items);
    } catch (e) {
      debugPrint('Error saving items in repository: $e');
      rethrow;
    }
  }

  /// Adds new items to the existing inventory.
  Future<void> addItems(List<FridgeItem> items) async {
    try {
      final currentItems = await getItems();
      await saveItems([...currentItems, ...items]);
    } catch (e) {
      debugPrint('Error adding items in repository: $e');
      rethrow;
    }
  }

  /// Updates a specific item in the inventory.
  Future<void> updateItem(FridgeItem item) async {
    try {
      final currentItems = await getItems();
      final index = currentItems.indexWhere((i) => i.id == item.id);

      if (index != -1) {
        final updatedItems = List<FridgeItem>.from(currentItems);
        updatedItems[index] = item;
        await saveItems(updatedItems);
      } else {
        debugPrint('Item with id ${item.id} not found for update');
      }
    } catch (e) {
      debugPrint('Error updating item in repository: $e');
      rethrow;
    }
  }

  /// Updates the quantity of an item and manages consumption state.
  Future<void> updateQuantity(FridgeItem item, int delta) async {
    try {
      var quantity = item.quantity + delta;
      var isConsumed = item.isConsumed;
      var consumptionDate = item.consumptionDate;

      if (quantity <= 0) {
        quantity = 0;
        isConsumed = true;
      } else if (isConsumed) {
        isConsumed = false;
        consumptionDate = null;
      }

      await updateItem(
        item.copyWith(
          quantity: quantity,
          isConsumed: isConsumed,
          consumptionDate: consumptionDate,
          clearConsumptionDate: consumptionDate == null,
        ),
      );
    } catch (e) {
      debugPrint('Error updating quantity in repository: $e');
      rethrow;
    }
  }

  /// Deletes all items from storage.
  Future<void> deleteAllItems() async {
    try {
      await _localStorageService.deleteAllItems();
    } catch (e) {
      debugPrint('Error deleting all items in repository: $e');
      rethrow;
    }
  }

  /// Deletes a single item by ID.
  Future<void> deleteItem(String id) async {
    try {
      final currentItems = await getItems();
      final updatedItems = currentItems.where((item) => item.id != id).toList();

      if (currentItems.length != updatedItems.length) {
        await saveItems(updatedItems);
      } else {
        debugPrint('Item with id $id not found for deletion');
      }
    } catch (e) {
      debugPrint('Error deleting item in repository: $e');
      rethrow;
    }
  }

  /// Gets only available (non-consumed) items.
  Future<List<FridgeItem>> getAvailableItems() async {
    try {
      final items = await getItems();
      return items.where((item) => item.quantity > 0).toList();
    } catch (e) {
      debugPrint('Error getting available items in repository: $e');
      rethrow;
    }
  }

  /// Gets items grouped by receipt ID.
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
