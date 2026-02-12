import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_sliver_app_bar.dart';

class InventoryPage extends StatelessWidget {
  final String title;

  const InventoryPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [InventorySliverAppBar(title: title)];
        },
        body: const InventoryList(),
      ),
    );
  }
}
