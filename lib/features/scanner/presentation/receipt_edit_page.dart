import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_footer.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_header.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_column_headers.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scanned_item_row.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/receipt_edit_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_verification_dialog.dart';

class ReceiptEditPage extends ConsumerStatefulWidget {
  const ReceiptEditPage({super.key});

  @override
  ConsumerState<ReceiptEditPage> createState() => _ReceiptEditPageState();
}

class _ReceiptEditPageState extends ConsumerState<ReceiptEditPage> {
  bool _isVerified = false;
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
      text: standardDateFormat.format(now),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showVerificationDialog();
      final items = ref.read(receiptEditViewModelProvider).items;
      if (items.isNotEmpty) {
        final detectedDate = items.first.receiptDate;
        if (detectedDate != null) {
          _dateController.text = standardDateFormat.format(detectedDate);
        }
      }
    });
  }

  void _onConfirmVerification() {
    if (!mounted) return;
    setState(() {
      _isVerified = true;
    });
    Navigator.of(context).pop(true);
  }

  void _showVerificationDialog() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ReceiptVerificationDialog(
          merchantController: _merchantController,
          dateController: _dateController,
          onConfirm: _onConfirmVerification,
          onCancel: () => Navigator.of(context).pop(false),
          onDateTap: () => _pickDate(context),
          onMerchantChanged: (value) {
            ref
                .read(receiptEditViewModelProvider.notifier)
                .updateMerchantName(value);
          },
        );
      },
    ).then((isConfirmed) {
      if (!mounted) return;
      if ((isConfirmed != true) && !_isVerified) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _pickDate(BuildContext context, {DateTime? initialDate}) async {
    final now = DateTime.now();

    DateTime? startInitDate = initialDate;
    if (startInitDate == null) {
      try {
        startInitDate = standardDateFormat.parse(_dateController.text);
      } catch (_) {}
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startInitDate ?? now,
      firstDate: DateTime(minDatePickerYear),
      lastDate: now.add(const Duration(days: datePickerFutureDays)),
    );

    if (!mounted) return;

    if (pickedDate != null) {
      setState(() {
        _dateController.text = standardDateFormat.format(pickedDate);
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
      appBar: _isVerified
          ? AppBar(
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
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_isVerified)
                    ReceiptHeader(
                      merchantController: _merchantController,
                      dateController: _dateController,
                      onMerchantChanged: (value) {
                        ref
                            .read(receiptEditViewModelProvider.notifier)
                            .updateMerchantName(value);
                      },
                      onDateTap: () => _pickDate(context),
                    ),

                  if (_isVerified)
                    Column(
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
                        const ReceiptColumnHeaders(),
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
                ],
              ),
            ),
          ),
          if (_isVerified)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ReceiptFooter(
                total: total,
                onSave: () async {
                  final itemsToSave = ref
                      .read(receiptEditViewModelProvider.notifier)
                      .getItemsForSave();

                  debugPrint("Saving ${itemsToSave.length} Items");

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
