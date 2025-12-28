import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_viewmodel.dart';

class InventoryList extends ConsumerWidget {
  const InventoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(inventoryDisplayListProvider);

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (items) {
        if (items.isEmpty) {
          final showOnlyAvailable = ref.watch(inventoryFilterProvider);
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
                key: ValueKey(item.itemId),
                itemId: item.itemId,
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
