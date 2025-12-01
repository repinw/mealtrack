import 'package:flutter/material.dart';
import 'package:mealtrack/bootstrap.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/shared/widgets/initialization_error_app.dart';

Future<void> main() async {
  final isInitialized = await bootstrap();
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
