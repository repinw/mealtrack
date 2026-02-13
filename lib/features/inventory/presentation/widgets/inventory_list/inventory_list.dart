import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_group_header.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_item_row/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_display_item.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';

class InventoryList extends ConsumerWidget {
  const InventoryList({super.key});
  static const double _scrollBottomSpacing = 144;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final listAsync = ref.watch(inventoryDisplayListProvider);
    final filter = ref.watch(inventoryFilterProvider);

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (items) {
        if (items.isEmpty) {
          final message = filter == InventoryFilterType.available
              ? l10n.noAvailableItems
              : l10n.noItemsFound;
          return Center(child: Text(message, style: textTheme.bodyMedium));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: _scrollBottomSpacing),
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
              return _ArchivedSectionHeader(section: item);
            } else if (item is InventorySpacerItem) {
              return const SizedBox.shrink();
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _ArchivedSectionHeader extends ConsumerWidget {
  const _ArchivedSectionHeader({required this.section});

  final InventoryArchivedSectionItem section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () {
        ref.read(archivedItemsExpandedProvider.notifier).toggle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              section.isExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.archive_outlined, size: 16),
            const SizedBox(width: 8),
            Text(
              l10n.archivedCount(section.archivedReceiptCount),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
