import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/action_button.dart';

class CounterPill extends StatelessWidget {
  final int quantity;
  final int initialQuantity;
  final bool isOutOfStock;
  final bool canIncrease;
  final ValueChanged<int> onUpdate;

  const CounterPill({
    super.key,
    required this.quantity,
    required this.initialQuantity,
    required this.isOutOfStock,
    this.canIncrease = true,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = isOutOfStock
        ? Colors.grey.shade200
        : const Color(0xFFE0F2F1);
    final badgeTextColor = isOutOfStock ? Colors.grey : Colors.teal;
    return Container(
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionButton(
            icon: Icons.add,
            onTap: canIncrease ? () => onUpdate(1) : null,
          ),

          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                '$quantity / $initialQuantity',
                style: TextStyle(
                  color: badgeTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ActionButton(
            icon: Icons.remove,
            onTap: isOutOfStock ? null : () => onUpdate(-1),
          ),
        ],
      ),
    );
  }
}
