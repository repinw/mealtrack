import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mealtrack/core/data/hive_initializer.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';

Future<bool> bootstrap(HiveInitializer hiveInitializer) async {
  try {
    // 1. Führe die übergebene Initialisierungslogik aus.
    await hiveInitializer.init();

    // 2. Führe die App-spezifische Konfiguration aus.
    if (!Hive.isAdapterRegistered(FridgeItemAdapter().typeId)) {
      Hive.registerAdapter(FridgeItemAdapter());
    }
    await Hive.openBox<FridgeItem>('inventory');
    return true;
  } catch (e, stackTrace) {
    debugPrint('Fehler bei der Initialisierung: $e');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}
