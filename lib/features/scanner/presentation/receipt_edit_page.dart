import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_footer.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_header.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scanned_item_row.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/receipt_edit_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';

class ReceiptEditPage extends ConsumerStatefulWidget {
  const ReceiptEditPage({super.key});

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
    final l10n = AppLocalizations.of(context)!;

    ref.listen<ReceiptEditState>(receiptEditViewModelProvider, (
      previous,
      next,
    ) {
      if ((previous?.items.isEmpty ?? true) && next.items.isNotEmpty) {
        // coverage:ignore-start
        _merchantController.text = next.initialStoreName;
        // coverage:ignore-end
      }
    });

    final viewModel = ref.watch(receiptEditViewModelProvider);
    final items = viewModel.items;
    final total = viewModel.total;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.verifyScan,
          style: Theme.of(context).appBarTheme.titleTextStyle,
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
                      Text(
                        l10n.positions,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        l10n.articles(viewModel.totalQuantity),
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
                        SizedBox(
                          width: ScannedItemRow.colQtyWidth,
                          child: Text(
                            l10n.amountAbbr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            l10n.brandDescription,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: ScannedItemRow.colWeightWidth,
                          child: Text(
                            l10n.weight,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: ScannedItemRow.colPriceWidth,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 28.0),
                            child: Text(
                              l10n.price,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
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
                final itemsToSave = <FridgeItem>[];
                FridgeItem? lastNormalItem;

                for (final item in items) {
                  if (!item.isDeposit) {
                    itemsToSave.add(item);
                    lastNormalItem = item;
                  } else if (item.isDiscount && lastNormalItem != null) {
                    final updatedDiscounts = Map<String, double>.from(
                      lastNormalItem.discounts,
                    );
                    updatedDiscounts[item.name] = item.unitPrice;

                    final updatedItem = lastNormalItem.copyWith(
                      discounts: updatedDiscounts,
                    );

                    itemsToSave.removeLast();
                    itemsToSave.add(updatedItem);
                    lastNormalItem = updatedItem;
                  }
                }

                await ref
                    .read(fridgeItemsProvider.notifier)
                    .addItems(itemsToSave);

                ref.invalidate(scannerViewModelProvider);

                if (context.mounted) {
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
