import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/provider/fridge_item_provider.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  bool _showOnlyAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(),
      body: _showOnlyAvailable ? _buildAvailableList() : _buildGroupedList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        Switch(
          value: _showOnlyAvailable,
          onChanged: (value) {
            setState(() {
              _showOnlyAvailable = value;
            });
          },
          activeThumbColor: Colors.green,
        ),
        if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: AppLocalizations.debugHiveReset,
            onPressed: () async {
              await ref.read(fridgeItemRepositoryProvider).deleteAllItems();
              if (mounted) {
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

  Widget _buildAvailableList() {
    final itemsAsync = ref.watch(availableFridgeItemsProvider);
    return itemsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text(AppLocalizations.noAvailableItems));
        }
        return _buildAvailableItemsList(items);
      },
    );
  }

  Widget _buildGroupedList() {
    final groupedAsync = ref.watch(groupedFridgeItemsProvider);
    return groupedAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (groupedItems) {
        if (groupedItems.isEmpty) {
          return const Center(child: Text(AppLocalizations.noItemsFound));
        }
        return _buildGroupedItemsList(groupedItems);
      },
    );
  }

  Widget _buildAvailableItemsList(List<FridgeItem> availableItems) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: availableItems.length,
            itemBuilder: (context, index) {
              final item = availableItems[index];
              return InventoryItemRow(key: ValueKey(item.id), item: item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedItemsList(
    List<MapEntry<String, List<FridgeItem>>> groupedItems,
  ) {
    final flattenedItems = <dynamic>[];
    for (final group in groupedItems) {
      final groupItems = group.value;
      if (groupItems.isEmpty) continue;

      flattenedItems.add(_GroupHeader(groupItems.first));
      flattenedItems.addAll(groupItems);
      flattenedItems.add(const _GroupSpacer());
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: flattenedItems.length,
            itemBuilder: (context, index) {
              final item = flattenedItems[index];

              if (item is _GroupHeader) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${item.item.storeName} - ${_formatDate(item.item.entryDate)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                );
              } else if (item is FridgeItem) {
                return InventoryItemRow(key: ValueKey(item.id), item: item);
              } else if (item is _GroupSpacer) {
                return const SizedBox(height: 16);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class _GroupHeader {
  final FridgeItem item;
  const _GroupHeader(this.item);
}

class _GroupSpacer {
  const _GroupSpacer();
}
