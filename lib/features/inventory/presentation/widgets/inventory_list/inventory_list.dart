import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/presentation/layout/scroll_spacing.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_item_row/inventory_item_row.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/archived_section_header.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_group_header.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_tabs.dart';
import 'package:mealtrack/features/inventory/domain/inventory_display_item.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';

class InventoryList extends ConsumerWidget {
  const InventoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final listAsync = ref.watch(inventoryDisplayListProvider);
    final filter = ref.watch(inventoryFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const InventoryTabs(),
        Divider(height: 1, color: colorScheme.surfaceContainerHighest),

        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (items) {
              if (items.isEmpty) {
                final message = filter == InventoryFilterType.available
                    ? l10n.noAvailableItems
                    : l10n.noItemsFound;
                return Center(
                  child: Text(
                    message,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(
                  bottom: ScrollSpacing.homeContentBottomPadding(context),
                ),
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
                  } else if (item is InventoryArchivedSectionItem) {
                    return ArchivedSectionHeader(section: item);
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
