import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/category_icon.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/counter_pill.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/item_details.dart';
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
    ref
        .read(fridgeItemsProvider.notifier)
        .updateQuantity(item, delta)
        .catchError((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.quantityUpdateFailed),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CategoryIcon(name: item.name),
            const SizedBox(width: 16),
            Expanded(
              child: ItemDetails(item: item, isOutOfStock: isOutOfStock),
            ),
            const SizedBox(width: 12),
            CounterPill(
              quantity: item.quantity,
              isOutOfStock: isOutOfStock,
              onUpdate: (delta) =>
                  _handleQuantityUpdate(context, ref, item, delta),
            ),
          ],
        ),
      ),
    );
  }
}
