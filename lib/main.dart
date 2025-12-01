import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/shared/widgets/initialization_error_app.dart';

Future<bool> _bootstrap() async {
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(FridgeItemAdapter());
    await Hive.openBox<FridgeItem>('inventory');
    return true;
  } catch (e, stackTrace) {
    debugPrint('Fehler bei der Initialisierung: $e');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}

Future<void> main() async {
  final isInitialized = await _bootstrap();
  runApp(isInitialized ? const MealTrack() : const InitializationErrorApp());
}

class MealTrack extends StatelessWidget {
  const MealTrack({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealTrack Hello World',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const InventoryPage(title: 'Digitaler Kühlschrank!'),
    );
  }
}
