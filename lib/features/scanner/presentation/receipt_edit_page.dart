import 'package:flutter/material.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_footer.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_header.dart';
import 'package:mealtrack/features/scanner/presentation/scanned_item_row.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_controller.dart';

class ReceiptEditPage extends StatefulWidget {
  final List<FridgeItem>? scannedItems;
  const ReceiptEditPage({super.key, this.scannedItems});

  @override
  ConsumerState<ReceiptEditPage> createState() => _ReceiptEditPageState();
}

class _ReceiptEditPageState extends ConsumerState<ReceiptEditPage> {
  late TextEditingController _merchantController;
  late TextEditingController _dateController;
  late ReceiptEditController _controller;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController();
    final now = DateTime.now();
    _dateController = TextEditingController(
      text: '${now.day}.${now.month}.${now.year}',
    );
    _controller = ReceiptEditController(widget.scannedItems);
    _merchantController.text = _controller.initialStoreName;

    // Update all items when the user changes the merchant name
    _merchantController.addListener(() {
      _controller.updateMerchantName(_merchantController.text);
    });

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _dateController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total sum
    final items = _controller.items;
    final total = _controller.total;

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
                        "${_controller.totalQuantity} Artikel",
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
                  ...items.asMap().entries.map((entry) {
                    int index = entry.key;
                    FridgeItem item = entry.value;

                    return ScannedItemRow(
                      key: ValueKey(index),
                      item: item,
                      onDelete: () => _controller.deleteItem(index),
                      onChanged: (newItem) =>
                          _controller.updateItem(index, newItem),
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
                debugPrint("Speichere ${items.length} Items");
              },
            ),
          ),
        ],
      ),
    );
  }
}
