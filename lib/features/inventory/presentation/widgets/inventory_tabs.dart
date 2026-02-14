import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InventoryTabs extends ConsumerWidget {
  const InventoryTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentFilter = ref.watch(inventoryFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab(
            context,
            ref,
            InventoryFilterType.all,
            l10n.filterAll,
            currentFilter == InventoryFilterType.all,
          ),
          _buildTab(
            context,
            ref,
            InventoryFilterType.available,
            l10n.filterAvailable,
            currentFilter == InventoryFilterType.available,
          ),
          _buildTab(
            context,
            ref,
            InventoryFilterType.consumed,
            l10n.filterEmpty,
            currentFilter == InventoryFilterType.consumed,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    WidgetRef ref,
    InventoryFilterType type,
    String label,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(inventoryFilterProvider.notifier).setFilter(type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surfaceContainerLow : null,
            border: isSelected
                ? Border.all(color: colorScheme.outlineVariant)
                : null,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
