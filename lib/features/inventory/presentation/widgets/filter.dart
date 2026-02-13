import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class FilterWidget extends ConsumerWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentFilter = ref.watch(inventoryFilterProvider);
    final filters = <InventoryFilterType, String>{
      InventoryFilterType.available: l10n.filterAvailable,
      InventoryFilterType.all: l10n.filterAll,
      InventoryFilterType.consumed: l10n.filterEmpty,
    };

    return PopupMenuButton<InventoryFilterType>(
      tooltip: l10n.filterAll,
      initialValue: currentFilter,
      icon: const Icon(Icons.filter_alt_outlined),
      onSelected: (value) {
        ref.read(inventoryFilterProvider.notifier).setFilter(value);
      },
      itemBuilder: (context) {
        return filters.entries
            .map(
              (entry) => PopupMenuItem<InventoryFilterType>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList();
      },
    );
  }
}
