import 'package:flutter/material.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_footer.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_header.dart';
import 'package:mealtrack/features/scanner/presentation/scanned_item_row.dart';

class ReceiptEditPage extends StatefulWidget {
  final List<FridgeItem>? scannedItems;
  const ReceiptEditPage({super.key, this.scannedItems});

  @override
  State<ReceiptEditPage> createState() => _ReceiptEditPageState();
}

class _ReceiptEditPageState extends State<ReceiptEditPage> {
  late TextEditingController _merchantController;
  late TextEditingController _dateController;

  final List<FridgeItem> _items = [];

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController();
    final now = DateTime.now();
    _dateController = TextEditingController(
      text: '${now.day}.${now.month}.${now.year}',
    );

    if (widget.scannedItems != null) {
      _items.addAll(widget.scannedItems!);

      // Try to extract the store name from the items
      if (_items.isNotEmpty) {
        final foundStoreName = _items
            .firstWhere(
              (i) => i.storeName.isNotEmpty,
              orElse: () => FridgeItem.create(rawText: '', storeName: ''),
            )
            .storeName;
        _merchantController.text = foundStoreName;
      }
    }

    // Update all items when the user changes the merchant name
    _merchantController.addListener(() {
      final newName = _merchantController.text;
      setState(() {
        for (var i = 0; i < _items.length; i++) {
          _items[i] = _items[i].copyWith(storeName: newName);
        }
      });
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  // Called when any item changes to recalculate the total
  void _onItemChanged(int index, FridgeItem newItem) {
    setState(() {
      _items[index] = newItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total sum
    double total = _items.fold(0, (sum, item) {
      return sum + (item.unitPrice ?? 0.0);
    });

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Scan überprüfen",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- Header ---
                  ReceiptHeader(
                    merchantController: _merchantController,
                    dateController: _dateController,
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "POSITIONEN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        // Total item count based on quantity
                        "${_items.fold(0, (sum, item) => sum + item.quantity)} Artikel",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- HEADER ROW ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: ScannedItemRow.colQtyWidth,
                          child: Text(
                            "ANZ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: const Text(
                            "MARKE / BESCHREIBUNG",
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: ScannedItemRow.colWeightWidth,
                          child: Text(
                            "GEWICHT",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const SizedBox(
                          width: ScannedItemRow.colPriceWidth,
                          child: Padding(
                            padding: EdgeInsets.only(right: 28.0),
                            child: Text(
                              "PREIS",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // --- List ---
                  ..._items.asMap().entries.map((entry) {
                    int index = entry.key;
                    FridgeItem item = entry.value;

                    return ScannedItemRow(
                      key: ValueKey(item),
                      item: item,
                      onDelete: () => _deleteItem(index),
                      onChanged: (newItem) => _onItemChanged(index, newItem),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // --- Footer (Pinned) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ReceiptFooter(
              total: total,
              onSave: () {
                // Save logic: _items contains the modified data
                // db.save(_items);
                debugPrint("Speichere ${_items.length} Items");
              },
            ),
          ),
        ],
      ),
    );
  }
}
