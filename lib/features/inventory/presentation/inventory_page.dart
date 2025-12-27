import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

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
              await ref.read(fridgeItemsProvider.notifier).deleteAll();
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
    final itemsAsync = ref.watch(fridgeItemsProvider);
    final showOnlyAvailable = ref.watch(inventoryFilterProvider);

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (allItems) {
        // Filter items if needed
        final items = showOnlyAvailable
            ? allItems.where((item) => item.quantity > 0).toList()
            : allItems;

        if (items.isEmpty) {
          return Center(
            child: Text(
              showOnlyAvailable
                  ? AppLocalizations.noAvailableItems
                  : AppLocalizations.noItemsFound,
            ),
          );
        }

        // Group items by receipt if not filtering
        if (showOnlyAvailable) {
          // Simple list when filtering
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return InventoryItemRow(
                key: ValueKey(items[index].id),
                item: items[index],
              );
            },
          );
        } else {
          // Grouped list
          final grouped = <String, List<FridgeItem>>{};
          for (final item in items) {
            final key = item.receiptId ?? '';
            grouped.putIfAbsent(key, () => []).add(item);
          }

          final groups = grouped.entries.toList();

          return ListView.builder(
            itemCount: groups.fold<int>(
              0,
              (sum, group) =>
                  sum + group.value.length + 2, // header + items + spacer
            ),
            itemBuilder: (context, index) {
              var currentIndex = 0;
              for (final group in groups) {
                // Header
                if (index == currentIndex) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${group.value.first.storeName} - ${DateFormat.yMd().format(group.value.first.entryDate)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                currentIndex++;

                // Items
                for (var i = 0; i < group.value.length; i++) {
                  if (index == currentIndex) {
                    return InventoryItemRow(
                      key: ValueKey(group.value[i].id),
                      item: group.value[i],
                    );
                  }
                  currentIndex++;
                }

                // Spacer
                if (index == currentIndex) {
                  return const SizedBox(height: 16);
                }
                currentIndex++;
              }
              return const SizedBox.shrink();
            },
          );
        }
      },
    );
  }
}
