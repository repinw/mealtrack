import 'package:flutter/material.dart';
import 'package:mealtrack/core/data/hive_initializer.dart';

Future<bool> bootstrap(HiveInitializer hiveInitializer) async {
  try {
    await hiveInitializer.init();

    return true;
  } catch (e, stackTrace) {
    debugPrint('Fehler bei der Initialisierung: $e');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}
