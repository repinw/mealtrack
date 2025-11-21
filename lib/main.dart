import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(FridgeItemAdapter());
  await Hive.openBox<FridgeItem>('inventory');
  runApp(const MealTrack());
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
