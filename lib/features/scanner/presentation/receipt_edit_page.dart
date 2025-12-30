import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_footer.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_header.dart';
import 'package:mealtrack/features/scanner/presentation/scanned_item_row.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_viewmodel.dart';

class ReceiptEditPage extends ConsumerStatefulWidget {
  final List<FridgeItem>? scannedItems;
  const ReceiptEditPage({super.key, this.scannedItems});

  @override
  ConsumerState<ReceiptEditPage> createState() => _ReceiptEditPageState();
}

class _ReceiptEditPageState extends ConsumerState<ReceiptEditPage> {
  late TextEditingController _merchantController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(receiptEditViewModelProvider);

    _merchantController = TextEditingController(
      text: initialState.initialStoreName,
    );

    final now = DateTime.now();
    _dateController = TextEditingController(
      text: '${now.day}.${now.month}.${now.year}',
    );
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReceiptEditState>(receiptEditViewModelProvider, (
      previous,
      next,
    ) {
      if ((previous?.items.isEmpty ?? true) && next.items.isNotEmpty) {
        _merchantController.text = next.initialStoreName;
      }
    });

    final viewModel = ref.watch(receiptEditViewModelProvider);
    final items = viewModel.items;
    final total = viewModel.total;

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
                  ReceiptHeader(
                    merchantController: _merchantController,
                    dateController: _dateController,
                    onMerchantChanged: (value) {
                      ref
                          .read(receiptEditViewModelProvider.notifier)
                          .updateMerchantName(value);
                    },
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
                        "${viewModel.totalQuantity} Artikel",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                  ...items.asMap().entries.map((entry) {
                    int index = entry.key;
                    FridgeItem item = entry.value;

                    return ScannedItemRow(
                      key: ValueKey(item.id),
                      item: item,
                      onDelete: () => ref
                          .read(receiptEditViewModelProvider.notifier)
                          .deleteItem(index),
                      onChanged: (newItem) => ref
                          .read(receiptEditViewModelProvider.notifier)
                          .updateItem(index, newItem),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ReceiptFooter(
              total: total,
              onSave: () async {
                debugPrint("Saving ${items.length} Items");
                await ref.read(fridgeItemsProvider.notifier).addItems(items);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
