import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_viewmodel.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(context, ref),
      body: _buildList(ref),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    final showOnlyAvailable = ref.watch(inventoryFilterProvider);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        Switch(
          value: showOnlyAvailable,
          onChanged: (value) {
            ref.read(inventoryFilterProvider.notifier).toggle();
          },
          activeThumbColor: Colors.green,
        ),
        if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: AppLocalizations.debugHiveReset,
            onPressed: () async {
              await ref
                  .read(inventoryViewModelProvider.notifier)
                  .deleteAllItems();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppLocalizations.debugDataDeleted),
                  ),
                );
              }
            },
          ),
      ],
    );
  }

  Widget _buildList(WidgetRef ref) {
    final listAsync = ref.watch(inventoryDisplayListProvider);

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (items) {
        if (items.isEmpty) {
          final showOnlyAvailable = ref.read(inventoryFilterProvider);
          return Center(
            child: Text(
              showOnlyAvailable
                  ? AppLocalizations.noAvailableItems
                  : AppLocalizations.noItemsFound,
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            if (item is InventoryHeaderItem) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${item.item.storeName} - ${DateFormat.yMd().format(item.item.entryDate)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            } else if (item is InventoryProductItem) {
              return InventoryItemRow(
                key: ValueKey(item.item.id),
                item: item.item,
              );
            } else if (item is InventorySpacerItem) {
              return const SizedBox(height: 16);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
