import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/counter_pill.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class InventoryItemRow extends ConsumerWidget {
  final String itemId;

  const InventoryItemRow({super.key, required this.itemId});

  void _handleQuantityUpdate(
    BuildContext context,
    WidgetRef ref,
    item,
    int delta,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (item.quantity + delta < 0) return;
    if (item.quantity + delta > item.initialQuantity) return;

    ref
        .read(fridgeItemsProvider.notifier)
        .updateQuantity(item, delta)
        .catchError((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.quantityUpdateFailed),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(fridgeItemProvider(itemId));

    if (item.id == 'loading') {
      return const SizedBox.shrink();
    }

    final isOutOfStock = item.quantity == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Brand and Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.brand ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        color: isOutOfStock
                            ? Colors.grey.shade400
                            : const Color(0xFF2D3142),
                        decoration: isOutOfStock
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    const Spacer(),
                    Text(
                      '${item.unitPrice.toStringAsFixed(2)}€ / Stk',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          CounterPill(
            quantity: item.quantity,
            initialQuantity: item.initialQuantity,
            isOutOfStock: isOutOfStock,
            canIncrease: item.quantity < item.initialQuantity,
            onUpdate: (delta) =>
                _handleQuantityUpdate(context, ref, item, delta),
          ),
        ],
      ),
    );
  }
}
