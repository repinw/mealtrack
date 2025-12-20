import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_item_repository.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, required this.title});

  final String title;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late Future<ValueListenable<Box<FridgeItem>>> _boxListenableFuture;
  bool _showOnlyAvailable = false;
  final FridgeItemRepository _repository = FridgeItemRepository();

  @override
  void initState() {
    super.initState();
    _boxListenableFuture = _repository.getBoxListenable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(),
      body: FutureBuilder<ValueListenable<Box<FridgeItem>>>(
        future: _boxListenableFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Keine Daten'));
          }

          return ValueListenableBuilder<Box<FridgeItem>>(
            valueListenable: snapshot.data!,
            builder: (context, box, _) {
              final allItems = box.values.toList();

              if (allItems.isEmpty) {
                return const Center(child: Text('Keine Artikel gefunden'));
              }

              if (_showOnlyAvailable) {
                return _buildAvailableItemsList(allItems);
              } else {
                return _buildGroupedItemsList(allItems);
              }
            },
          );
        },
      ),
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
            tooltip: 'Debug: Hive Reset',
            onPressed: () async {
              await _repository.deleteAllItems();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debug: Alle Daten gelöscht')),
                );
              }
            },
          ),
      ],
    );
  }

  Widget _buildAvailableItemsList(List<FridgeItem> allItems) {
    final availableItems = allItems.where((item) => item.quantity > 0).toList();

    if (availableItems.isEmpty) {
      return const Center(child: Text('Keine verfügbaren Artikel'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: availableItems.length,
            itemBuilder: (context, index) {
              return InventoryItemRow(item: availableItems[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedItemsList(List<FridgeItem> allItems) {
    final grouped = _groupItems(allItems);
    final sortedKeys = _sortKeysByDate(grouped);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final key = sortedKeys[index];
              final groupItems = grouped[key]!;
              final firstItem = groupItems.first;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${firstItem.storeName} - ${firstItem.entryDate.day}.${firstItem.entryDate.month}.${firstItem.entryDate.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...groupItems.map((item) => InventoryItemRow(item: item)),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Map<String, List<FridgeItem>> _groupItems(List<FridgeItem> items) {
    final Map<String, List<FridgeItem>> grouped = {};
    for (var item in items) {
      final key =
          item.receiptId ??
          '${item.storeName}_${item.entryDate.year}${item.entryDate.month}${item.entryDate.day}';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  List<String> _sortKeysByDate(Map<String, List<FridgeItem>> grouped) {
    return grouped.keys.toList()..sort((a, b) {
      final dateA = grouped[a]!.first.entryDate;
      final dateB = grouped[b]!.first.entryDate;
      return dateB.compareTo(dateA);
    });
  }
}
