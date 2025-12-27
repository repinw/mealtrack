import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/action_button.dart';

class CounterPill extends StatefulWidget {
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
  State<CounterPill> createState() => _CounterPillState();
}

class _CounterPillState extends State<CounterPill> {
  late int _localQuantity;

  @override
  void initState() {
    super.initState();
    _localQuantity = widget.quantity;
  }

  @override
  void didUpdateWidget(CounterPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      _localQuantity = widget.quantity;
    }
  }

  void _handleUpdate(int delta) {
    setState(() {
      _localQuantity += delta;
    });
    widget.onUpdate(delta);
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = _localQuantity == 0;

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
            onTap: isOutOfStock ? null : () => _handleUpdate(-1),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$_localQuantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isOutOfStock ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          ActionButton(icon: Icons.add, onTap: () => _handleUpdate(1)),
        ],
      ),
    );
  }
}
