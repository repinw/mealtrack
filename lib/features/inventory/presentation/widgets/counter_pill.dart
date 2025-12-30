import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/action_button.dart';

class CounterPill extends StatelessWidget {
  final int quantity;
  final bool isOutOfStock;
  final ValueChanged<int> onUpdate;

  const CounterPill({
    super.key,
    required this.quantity,
    required this.isOutOfStock,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionButton(
            icon: Icons.remove,
            onTap: isOutOfStock ? null : () => onUpdate(-1),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isOutOfStock ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          ActionButton(icon: Icons.add, onTap: () => onUpdate(1)),
        ],
      ),
    );
  }
}
