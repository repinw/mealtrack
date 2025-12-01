import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';

Future<bool> bootstrap({String? path}) async {
  try {
    await Hive.initFlutter(path);
    Hive.registerAdapter(FridgeItemAdapter());
    await Hive.openBox<FridgeItem>('inventory');
    return true;
  } catch (e, stackTrace) {
    debugPrint('Fehler bei der Initialisierung: $e');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}
