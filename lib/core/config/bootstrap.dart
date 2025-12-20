import 'package:flutter/material.dart';
import 'package:mealtrack/core/data/hive_initializer.dart';
import 'package:mealtrack/features/inventory/data/fridge_item_repository.dart';

Future<bool> bootstrap(HiveInitializer hiveInitializer) async {
  try {
    await hiveInitializer.init();
    FridgeItemRepository fridgeItemRepository = FridgeItemRepository();
    await fridgeItemRepository.init();

    return true;
  } catch (e, stackTrace) {
    debugPrint('Fehler bei der Initialisierung: $e');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}
