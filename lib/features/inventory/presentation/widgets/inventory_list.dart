import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_group_header.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_tabs.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';

class InventoryList extends ConsumerWidget {
  const InventoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(inventoryDisplayListProvider);
    final filter = ref.watch(inventoryFilterProvider);

    return Column(
      children: [
        const InventoryTabs(),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),

        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (items) {
              if (items.isEmpty) {
                final message = filter == InventoryFilterType.available
                    ? AppLocalizations.noAvailableItems
                    : AppLocalizations.noItemsFound;
                return Center(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  if (item is InventoryHeaderItem) {
                    return InventoryGroupHeader(header: item);
                  } else if (item is InventoryProductItem) {
                    return InventoryItemRow(
                      key: ValueKey(item.itemId),
                      itemId: item.itemId,
                    );
                  } else if (item is InventorySpacerItem) {
                    return const SizedBox.shrink();
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
