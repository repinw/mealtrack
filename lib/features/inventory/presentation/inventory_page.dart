import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_speed_dial.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_app_bar.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      scannerViewModelProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: InventoryAppBar(title: title),
      floatingActionButton: const InventorySpeedDial(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : const InventoryList(),
    );
  }
}
