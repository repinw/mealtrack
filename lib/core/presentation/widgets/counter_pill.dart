import 'package:flutter/material.dart';
import 'package:mealtrack/core/presentation/widgets/action_button.dart';

class CounterPill extends StatelessWidget {
  final int quantity;
  final int? maxQuantity;
  final bool isOutOfStock;
  final bool canIncrease;
  final bool canDecrease;
  final ValueChanged<int>? onUpdate;

  const CounterPill({
    super.key,
    required this.quantity,
    this.maxQuantity,
    this.isOutOfStock = false,
    this.canIncrease = true,
    this.canDecrease = true,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMinusButton(),
          _buildQuantityText(context),
          _buildPlusButton(),
        ],
      ),
    );
  }

  Widget _buildMinusButton() {
    return ActionButton(
      icon: Icons.remove,
      onTap: (!canDecrease || onUpdate == null) ? null : () => onUpdate!(-1),
    );
  }

  Widget _buildPlusButton() {
    return ActionButton(
      icon: Icons.add,
      onTap: (!canIncrease || onUpdate == null) ? null : () => onUpdate!(1),
    );
  }

  Widget _buildQuantityText(BuildContext context) {
    final text = maxQuantity != null ? '$quantity / $maxQuantity' : '$quantity';

    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
