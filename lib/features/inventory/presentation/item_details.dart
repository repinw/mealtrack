import 'package:flutter/material.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

class ItemDetails extends StatelessWidget {
  final FridgeItem item;
  final bool isOutOfStock;

  const ItemDetails({
    super.key,
    required this.item,
    required this.isOutOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.brand != null && item.brand!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            item.brand!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        Text(
          item.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isOutOfStock ? Colors.grey : Colors.black87,
            decoration: isOutOfStock ? TextDecoration.lineThrough : null,
          ),
        ),
        if (item.weight != null && item.weight!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            item.weight!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
