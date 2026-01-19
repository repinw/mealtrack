import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/core/presentation/widgets/counter_pill.dart';

class ShoppingListItemRow extends ConsumerWidget {
  final ShoppingListItem item;

  const ShoppingListItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Checkbox
          Checkbox(
            value: item.isChecked,
            onChanged: (value) {
              if (value != null) {
                ref.read(shoppingListProvider.notifier).toggleItem(item.id);
              }
            },
          ),
          const SizedBox(width: 16), // Match standard spacing
          // Name and Brand
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
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                          color: item.isChecked
                              ? Colors.grey.shade400
                              : const Color(0xFF2D3142),
                          decoration: item.isChecked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right Counter Pill
          _buildCounterPill(context, ref),
        ],
      ),
    );
  }

  Widget _buildCounterPill(BuildContext context, WidgetRef ref) {
    return CounterPill(
      quantity: item.quantity,
      isOutOfStock:
          false,
      canDecrease: item.quantity > 1,
      onUpdate: (delta) {
        ref.read(shoppingListProvider.notifier).updateQuantity(item.id, delta);
      },
    );
  }
}
