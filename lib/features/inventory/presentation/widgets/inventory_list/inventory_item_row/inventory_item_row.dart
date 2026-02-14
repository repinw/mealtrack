import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_item_row/category_icon.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_item_row/remaining_progress_bar.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_item_row/status_line.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InventoryItemRow extends ConsumerStatefulWidget {
  final String itemId;

  const InventoryItemRow({super.key, required this.itemId});

  @override
  ConsumerState<InventoryItemRow> createState() => _InventoryItemRowState();
}

class _InventoryItemRowState extends ConsumerState<InventoryItemRow> {
  bool _isActionPanelVisible = false;
  static const Set<String> _weightUnits = {
    'mg',
    'g',
    'kg',
    'ml',
    'cl',
    'l',
    'oz',
    'lb',
    'lbs',
  };

  double _remainingRatio(int quantity, int initialQuantity) {
    if (initialQuantity <= 0) return 0;
    return (quantity / initialQuantity).clamp(0.0, 1.0);
  }

  String _remainingLabel(
    int quantity,
    int initialQuantity,
    _ParsedWeight? parsedWeight,
  ) {
    if (parsedWeight == null) {
      return '$quantity / $initialQuantity';
    }

    final remainingWeight = parsedWeight.amount * quantity;
    final totalWeight = parsedWeight.amount * initialQuantity;
    final unit = parsedWeight.unit;

    return '${_formatWeightAmount(remainingWeight)} $unit / ${_formatWeightAmount(totalWeight)} $unit';
  }

  _ParsedWeight? _parseWeight(String? rawWeight) {
    if (rawWeight == null) return null;
    final normalized = rawWeight.trim();
    if (normalized.isEmpty) return null;

    final match = RegExp(
      r'([0-9]+(?:[.,][0-9]+)?)\s*([a-zA-Z]+)',
    ).firstMatch(normalized);

    if (match == null) return null;

    final amount = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    final unit = match.group(2)?.toLowerCase();
    if (amount == null || unit == null || unit.isEmpty) return null;
    if (!_weightUnits.contains(unit)) return null;

    return _ParsedWeight(amount: amount, unit: unit);
  }

  String _formatWeightAmount(double amount) {
    if ((amount - amount.roundToDouble()).abs() < 0.001) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }

  void _addItemToShoppingList(
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

  String _removedAmountLabel(int removedUnits, _ParsedWeight? parsedWeight) {
    if (parsedWeight == null) {
      return '$removedUnits Stück';
    }

    final removedWeight = parsedWeight.amount * removedUnits;
    return '${_formatWeightAmount(removedWeight)} ${parsedWeight.unit}';
  }

  Future<void> _mockRemoveRandomAmount(
    BuildContext context,
    WidgetRef ref,
    FridgeItem item, {
    required _ParsedWeight? parsedWeight,
    required String actionLabel,
  }) async {
    if (item.quantity <= 0) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final fridgeItemsNotifier = ref.read(fridgeItemsProvider.notifier);
    final removedUnits = Random().nextInt(item.quantity) + 1;
    try {
      await fridgeItemsNotifier.updateQuantity(item, -removedUnits);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Aktion fehlgeschlagen')),
      );
      return;
    }

    final removedLabel = _removedAmountLabel(removedUnits, parsedWeight);
    messenger.showSnackBar(
      SnackBar(
        content: Text('$removedLabel entfernt ($actionLabel)'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () {
            fridgeItemsNotifier.updateQuantity(item, removedUnits);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(fridgeItemProvider(widget.itemId));
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (item.id == 'loading') {
      return const SizedBox.shrink();
    }

    final isOutOfStock = item.quantity == 0;
    final isArchived = item.isArchived;
    final brand = item.brand?.trim() ?? '';
    final hasBrand = brand.isNotEmpty;
    final inactiveTextColor = colorScheme.onSurfaceVariant.withValues(
      alpha: 0.65,
    );
    final activeTextColor = colorScheme.onSurface;
    final nameTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: isOutOfStock || isArchived ? inactiveTextColor : activeTextColor,
      decoration: isOutOfStock ? TextDecoration.lineThrough : null,
    );
    final brandTextStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface.withValues(alpha: 0.58),
    );
    final parsedWeight = _parseWeight(item.weight);
    final hasWeight = parsedWeight != null;
    final remainingRatio = _remainingRatio(item.quantity, item.initialQuantity);
    final remainingLabel = _remainingLabel(
      item.quantity,
      item.initialQuantity,
      parsedWeight,
    );

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
        _addItemToShoppingList(context, ref, item);
        return false;
      },
      child: InkWell(
        onTap: () {
          setState(() {
            _isActionPanelVisible = !_isActionPanelVisible;
          });
        },
        onLongPress: () => _addItemToShoppingList(context, ref, item),
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
              CategoryIcon(name: item.category ?? item.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: nameTextStyle,
                          ),
                        ),
                        if (hasBrand) ...[
                          const SizedBox(width: 8),
                          Text(
                            brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: brandTextStyle,
                          ),
                        ],
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isActionPanelVisible
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    if (isOutOfStock || isArchived) ...[
                      const SizedBox(height: 6),
                      StatusLine(
                        text: isArchived ? l10n.archived : l10n.filterEmpty,
                        color: isArchived
                            ? colorScheme.secondary
                            : colorScheme.error,
                      ),
                    ],
                    const SizedBox(height: 10),
                    RemainingProgressBar(
                      ratio: remainingRatio,
                      stockLabel: remainingLabel,
                      segmentedByUnits: hasWeight,
                      totalUnits: item.initialQuantity,
                      remainingUnits: item.quantity,
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: (isArchived || isOutOfStock)
                                    ? null
                                    : () => _mockRemoveRandomAmount(
                                        context,
                                        ref,
                                        item,
                                        parsedWeight: parsedWeight,
                                        actionLabel: 'Wegwerfen',
                                      ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                label: const Text('Wegwerfen'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: (isArchived || isOutOfStock)
                                    ? null
                                    : () => _mockRemoveRandomAmount(
                                        context,
                                        ref,
                                        item,
                                        parsedWeight: parsedWeight,
                                        actionLabel: 'Essen',
                                      ),
                                icon: const Icon(
                                  Icons.restaurant_menu,
                                  size: 18,
                                ),
                                label: const Text('Essen'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      crossFadeState: _isActionPanelVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 180),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParsedWeight {
  const _ParsedWeight({required this.amount, required this.unit});

  final double amount;
  final String unit;
}
