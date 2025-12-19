import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealtrack/features/inventory/data/discount.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';

class FridgeItemRepository {
  static const String _boxName = 'fridge_items';

  /// Initializes the repository.
  /// Should be called at the start of the app (e.g. in main.dart).
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(DiscountAdapter().typeId)) {
      Hive.registerAdapter(DiscountAdapter());
    }
    await Hive.openBox<FridgeItem>(_boxName);
  }

  Future<void> saveItems(List<FridgeItem> items) async {
    final box = await _getBox();
    await box.addAll(items);
  }

  Future<List<FridgeItem>> getAllItems() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> deleteAllItems() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<ValueListenable<Box<FridgeItem>>> getBoxListenable() async {
    final box = await _getBox();
    return box.listenable();
  }

  Future<Box<FridgeItem>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<FridgeItem>(_boxName);
    }
    return await Hive.openBox<FridgeItem>(_boxName);
  }
}
