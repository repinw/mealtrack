import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealtrack/features/inventory/data/discount.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';

class FridgeItemRepository {
  static const String _boxName = 'fridge_items';

  Future<void> saveItems(List<FridgeItem> items) async {
    _registerAdapters();
    final box = await Hive.openBox<FridgeItem>(_boxName);
    await box.addAll(items);
  }

  Future<List<FridgeItem>> getAllItems() async {
    _registerAdapters();
    final box = await Hive.openBox<FridgeItem>(_boxName);
    return box.values.toList();
  }

  Future<void> deleteAllItems() async {
    _registerAdapters();
    final box = await Hive.openBox<FridgeItem>(_boxName);
    await box.clear();
  }

  Future<ValueListenable<Box<FridgeItem>>> getBoxListenable() async {
    _registerAdapters();
    final box = await Hive.openBox<FridgeItem>(_boxName);
    return box.listenable();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(DiscountAdapter().typeId)) {
      Hive.registerAdapter(DiscountAdapter());
    }
  }
}
