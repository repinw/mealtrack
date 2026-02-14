import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/presentation/widgets/counter_pill.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_amount_picker_dialog.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InventoryItemRow extends ConsumerStatefulWidget {
  final String itemId;

  const InventoryItemRow({super.key, required this.itemId});

  @override
  ConsumerState<InventoryItemRow> createState() => InventoryItemRowState();
}

class InventoryItemRowState extends ConsumerState<InventoryItemRow> {
  void addItemToShoppingList(
    BuildContext context,
    WidgetRef ref,
    FridgeItem item,
  ) {
    final l10n = AppLocalizations.of(context)!;
    ref
        .read(shoppingListProvider.notifier)
        .addItem(item.name, brand: item.brand, unitPrice: item.unitPrice);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.itemAddedToShoppingList(item.name))),
      );
    }
  }

  Future<void> applyAmountAction(
    BuildContext context,
    FridgeItem item, {
    required FridgeItemRemovalType removalType,
    required String actionLabel,
  }) async {
    if (item.isArchived || item.isConsumed) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final selectedAmount = await InventoryAmountPickerDialog.show(
      context,
      item: item,
      actionLabel: actionLabel,
    );
    if (selectedAmount == null || selectedAmount <= fridgeItemAmountEpsilon) {
      return;
    }

    try {
      await ref
          .read(fridgeItemsProvider.notifier)
          .updateAmount(item, selectedAmount, removalType: removalType);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.quantityUpdateFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    final amountLabel =
        '${formatInventoryAmount(selectedAmount)} ${item.resolvedAmountUnit.symbol}';
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('$amountLabel entfernt ($actionLabel)'),
        action: SnackBarAction(
          label: 'Rueckgaengig',
          onPressed: () {
            ref
                .read(fridgeItemsProvider.notifier)
                .updateAmount(
                  item,
                  selectedAmount,
                  removalType: removalType,
                  isUndo: true,
                )
                .catchError((_) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.quantityUpdateFailed),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                });
          },
        ),
      ),
    );
  }

  String amountSummaryLabel(FridgeItem item) {
    final remaining = formatInventoryAmount(item.resolvedRemainingAmountBase);
    final initial = formatInventoryAmount(item.resolvedInitialAmountBase);
    final unit = item.resolvedAmountUnit.symbol;
    return '$remaining / $initial $unit';
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(fridgeItemProvider(widget.itemId));
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (item.id == 'loading') {
      return const SizedBox.shrink();
    }

    final isOutOfStock = item.isConsumed;
    final isArchived = item.isArchived;
    final isActionEnabled = !isArchived && !isOutOfStock;

    return Dismissible(
      key: Key('inventory_row_${item.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: Icon(Icons.shopping_cart, color: colorScheme.onPrimary),
      ),
      confirmDismiss: (direction) async {
        addItemToShoppingList(context, ref, item);
        return false;
      },
      child: InkWell(
        onLongPress: () => addItemToShoppingList(context, ref, item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: colorScheme.surfaceContainerHighest),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.brand != null && item.brand!.isNotEmpty)
                      Text(
                        item.brand!,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (item.brand != null && item.brand!.isNotEmpty)
                      const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              color: isOutOfStock || isArchived
                                  ? colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.65,
                                    )
                                  : colorScheme.onSurface,
                              decoration: isOutOfStock
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.unitPriceLabel(
                            item.unitPrice.toStringAsFixed(2),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amountSummaryLabel(item),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: isActionEnabled
                              ? () => applyAmountAction(
                                  context,
                                  item,
                                  removalType: FridgeItemRemovalType.thrownAway,
                                  actionLabel: 'Wegwerfen',
                                )
                              : null,
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Wegwerfen'),
                        ),
                        OutlinedButton.icon(
                          onPressed: isActionEnabled
                              ? () => applyAmountAction(
                                  context,
                                  item,
                                  removalType: FridgeItemRemovalType.eaten,
                                  actionLabel: 'Essen',
                                )
                              : null,
                          icon: const Icon(Icons.restaurant, size: 16),
                          label: const Text('Essen'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CounterPill(
                quantity: item.quantity,
                maxQuantity: item.initialQuantity,
                isOutOfStock: isOutOfStock,
                canIncrease: false,
                canDecrease: false,
                onUpdate: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
