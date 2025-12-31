import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
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
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      color: const Color(0xFFF4F7F9),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('dd.MM.yyyy').format(item.entryDate)} • ${item.storeName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF455A64),
                            ),
                          ),
                          const Spacer(),
                          if (item.isFullyConsumed)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                onTap: () {
                                  ref
                                      .read(fridgeItemsProvider.notifier)
                                      .deleteItemsByReceipt(item.receiptId);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.orange.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.archive_outlined,
                                        size: 14,
                                        color: Colors.orange.shade800,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.archive,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.entries(item.itemCount),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
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
