import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';

class InventoryItemRow extends StatelessWidget {
  final FridgeItem item;

  const InventoryItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
            _buildCategoryIcon(item.rawText),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.rawText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? Colors.grey : Colors.black87,
                      decoration: isOutOfStock
                          ? TextDecoration.lineThrough
                          : null,
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
              ),
            ),
            const SizedBox(width: 12),
            _buildCounterPill(isOutOfStock),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String text) {
    IconData iconData = Icons.kitchen;
    final lowerText = text.toLowerCase();

    if (lowerText.contains('milch') ||
        lowerText.contains('joghurt') ||
        lowerText.contains('käse') ||
        lowerText.contains('sahne')) {
      iconData = Icons.local_drink;
    } else if (lowerText.contains('fleisch') ||
        lowerText.contains('wurst') ||
        lowerText.contains('hähnchen') ||
        lowerText.contains('fisch')) {
      iconData = Icons.restaurant;
    } else if (lowerText.contains('apfel') ||
        lowerText.contains('banane') ||
        lowerText.contains('gemüse') ||
        lowerText.contains('salat') ||
        lowerText.contains('obst')) {
      iconData = Icons.eco;
    } else if (lowerText.contains('brot') ||
        lowerText.contains('brötchen') ||
        lowerText.contains('toast')) {
      iconData = Icons.breakfast_dining;
    } else if (lowerText.contains('ei') || lowerText.contains('eier')) {
      iconData = Icons.egg;
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade100,
      child: Icon(iconData, color: Colors.grey.shade700, size: 22),
    );
  }

  Widget _buildCounterPill(bool isOutOfStock) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.remove,
            onTap: isOutOfStock
                ? null
                : () async {
                    if (item.quantity > 0) {
                      item.quantity--;
                      if (item.quantity == 0) {
                        item.markAsConsumed();
                      }
                      await item.save();
                    }
                  },
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isOutOfStock ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          _buildActionButton(
            icon: Icons.add,
            onTap: () async {
              item.quantity++;
              if (item.isConsumed) {
                item.isConsumed = false;
                item.consumptionDate = null;
              }
              await item.save();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
