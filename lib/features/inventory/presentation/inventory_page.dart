import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_app_bar.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_list.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: InventoryAppBar(title: title),
      body: const InventoryList(),
    );
  }
}
