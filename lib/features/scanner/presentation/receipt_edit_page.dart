import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

class _ReceiptEditPageState extends ConsumerState<ReceiptEditPage>
    with SingleTickerProviderStateMixin {
  bool _isVerified = false;
  late TextEditingController _merchantController;
  late TextEditingController _dateController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(receiptEditViewModelProvider);

    _merchantController = TextEditingController(
      text: initialState.initialStoreName,
    );

    final now = DateTime.now();
    _dateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(now),
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // AI Date Detection - Header Verification Dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showVerificationDialog();
      // If there is a detected date, update the controller/state before showing dialog if needed
      // But the controller is already init with 'now'.
      // We should check if we want to overwrite 'now' with 'detected' if available.
      final items = ref.read(receiptEditViewModelProvider).items;
      if (items.isNotEmpty) {
        final detectedDate = items.first.receiptDate;
        // ReceiptDate in items IS the detected date (or fallback from parser).
        // The parser logic: rootReceiptDate ??= DateTime.now().
        // So items.first.receiptDate is likely already set to a valid date.
        if (detectedDate != null) {
          _dateController.text = DateFormat('dd.MM.yyyy').format(detectedDate);
          // No need to call updateReceiptDate here as it matches the item state already.
        }
      }
    });
  }

  void _onConfirmVerification() {
    setState(() {
      _isVerified = true;
    });
    _animController.forward();
    Navigator.of(context).pop();
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to verify
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'receipt_header',
                child: Material(
                  color: Colors.transparent,
                  child: ReceiptHeader(
                    merchantController: _merchantController,
                    dateController: _dateController,
                    onMerchantChanged: (value) {
                      ref
                          .read(receiptEditViewModelProvider.notifier)
                          .updateMerchantName(value);
                    },
                    onDateTap: () => _pickDate(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _onConfirmVerification,
                  child: const Text(
                    "Bestätigen",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, {DateTime? initialDate}) async {
    final now = DateTime.now();

    // Parse current text to find initial date if possible
    DateTime? startInitDate = initialDate;
    if (startInitDate == null) {
      try {
        startInitDate = DateFormat('dd.MM.yyyy').parse(_dateController.text);
      } catch (_) {}
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startInitDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd.MM.yyyy').format(pickedDate);
      });
      ref
          .read(receiptEditViewModelProvider.notifier)
          .updateReceiptDate(pickedDate);
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _dateController.dispose();
    _animController.dispose();
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
      // Removed extendBodyBehindAppBar to prevent overlap issues
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AppBar(
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
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Only show the header destination once verification is done (or starts flying).
                  // Hero will fly TO this widget. If it is opacity 0, flight might end invisibly?
                  // No, Hero animation handles the transition. We want the destination to be "there" but invisible
                  // until the moment the flight ends or valid state is reached.
                  // Actually, standard Hero behavior: Destination is hidden *during* flight.
                  // But here Destination is visible *before* flight (bad).
                  // So we hide it initially.
                  Opacity(
                    opacity: _isVerified ? 1.0 : 0.0,
                    child: Hero(
                      tag: 'receipt_header',
                      child: Material(
                        color: Colors.transparent,
                        child: ReceiptHeader(
                          merchantController: _merchantController,
                          dateController: _dateController,
                          onMerchantChanged: (value) {
                            ref
                                .read(receiptEditViewModelProvider.notifier)
                                .updateMerchantName(value);
                          },
                          onDateTap: () => _pickDate(context),
                        ),
                      ),
                    ),
                  ),

                  if (_isVerified)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
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
                                      padding: const EdgeInsets.only(
                                        right: 28.0,
                                      ),
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
                ],
              ),
            ),
          ),
          if (_isVerified)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
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
            ),
        ],
      ),
    );
  }
}
