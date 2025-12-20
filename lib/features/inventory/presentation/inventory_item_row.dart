import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/provider/fridge_item_provider.dart';

class InventoryItemRow extends ConsumerStatefulWidget {
  final FridgeItem item;

  const InventoryItemRow({super.key, required this.item});

  @override
  ConsumerState<InventoryItemRow> createState() => _InventoryItemRowState();
}

class _InventoryItemRowState extends ConsumerState<InventoryItemRow> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
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

  Future<void> _updateItemQuantity(int delta) async {
    try {
      await ref
          .read(fridgeItemControllerProvider)
          .updateQuantity(widget.item, delta);
    } catch (e) {
      if (!mounted) return;
      // Fehlerbehandlung: UI zeigt Snackbar, State wird durch Provider/Hive korrigiert
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update item. Please try again.'),
        ),
      );
    }
  }

  Widget _buildCategoryIcon(String text) {
    IconData iconData = Icons.kitchen;
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
            onTap: isOutOfStock ? null : () => _updateItemQuantity(-1),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${widget.item.quantity}',
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
            onTap: () => _updateItemQuantity(1),
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
