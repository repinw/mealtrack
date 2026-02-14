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
    final listBottomPadding = ScrollSpacing.homeContentBottomPadding(context);

    return listAsync.when(
      loading: () => ListView(
        padding: EdgeInsets.only(bottom: listBottomPadding),
        children: const [
          InventoryTabs(),
          InventoryTabsDivider(),
          SizedBox(height: 24),
          Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (error, stack) => ListView(
        padding: EdgeInsets.only(bottom: listBottomPadding),
        children: [
          const InventoryTabs(),
          const InventoryTabsDivider(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $error'),
          ),
        ],
      ),
      data: (items) {
        final message = filter == InventoryFilterType.available
            ? l10n.noAvailableItems
            : l10n.noItemsFound;
        final contentItemCount = items.isEmpty ? 1 : items.length;

        return ListView.builder(
          padding: EdgeInsets.only(bottom: listBottomPadding),
          itemCount: contentItemCount + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const InventoryTabs();
            }
            if (index == 1) {
              return const InventoryTabsDivider();
            }

            if (items.isEmpty && index == 2) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              );
            }

            if (items.isEmpty) {
              return const SizedBox.shrink();
            }

            final item = items[index - 2];
            return _buildDisplayItem(item);
          },
        );
      },
    );
  }

  Widget _buildDisplayItem(InventoryDisplayItem item) {
    return switch (item) {
      InventoryHeaderItem() => InventoryGroupHeader(header: item),
      InventoryProductItem() => InventoryItemRow(
        key: ValueKey(item.itemId),
        itemId: item.itemId,
      ),
      InventoryArchivedSectionItem() => ArchivedSectionHeader(section: item),
      InventorySpacerItem() => const SizedBox.shrink(),
    };
  }
}

class InventoryTabsDivider extends StatelessWidget {
  const InventoryTabsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
