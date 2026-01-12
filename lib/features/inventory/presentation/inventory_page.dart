import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_app_bar.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list.dart';

class InventoryPage extends StatelessWidget {
  final String title;

  const InventoryPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: InventoryAppBar(title: title),
      body: const Column(children: [Expanded(child: InventoryList())]),
    );
  }
}
