import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';

void main() {
  runApp(const MealTrack());
}

class MealTrack extends StatelessWidget {
  const MealTrack({super.key});

  // This widget is the root of your application.
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
