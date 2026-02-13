import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_list.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/inventory_sliver_app_bar.dart';

class InventoryPage extends StatelessWidget {
  final String title;
  final WidgetBuilder? sharingPageBuilder;
  final WidgetBuilder? settingsPageBuilder;

  const InventoryPage({
    super.key,
    required this.title,
    this.sharingPageBuilder,
    this.settingsPageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InventoryAppBar(title: title),
      body: const Column(children: [Expanded(child: InventoryList())]),
    );
  }
}
