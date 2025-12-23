import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/inventory_providers.dart';

class InventoryItemRow extends ConsumerWidget {
  final FridgeItem item;

  const InventoryItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _CategoryIcon(name: item.name),
            const SizedBox(width: 16),
            Expanded(
              child: _ItemDetails(item: item, isOutOfStock: isOutOfStock),
            ),
            const SizedBox(width: 12),
            _CounterPill(
              quantity: item.quantity,
              isOutOfStock: isOutOfStock,
              onUpdate: (delta) => _updateItemQuantity(context, ref, delta),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateItemQuantity(
    BuildContext context,
    WidgetRef ref,
    int delta,
  ) async {
    try {
      await ref.read(fridgeItemsProvider.notifier).updateQuantity(item, delta);
    } catch (e) {
      if (!context.mounted) return;
      // Fehlerbehandlung: UI zeigt Snackbar, State wird durch Provider/Hive korrigiert
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update item. Please try again.'),
        ),
      );
    }
  }
}

class _CategoryIcon extends StatelessWidget {
  final String name;

  const _CategoryIcon({required this.name});

  @override
  Widget build(BuildContext context) {
    const iconData = Icons.kitchen;
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade100,
      child: Icon(iconData, color: Colors.grey.shade700, size: 22),
    );
  }
}

class _ItemDetails extends StatelessWidget {
  final FridgeItem item;
  final bool isOutOfStock;

  const _ItemDetails({required this.item, required this.isOutOfStock});

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

class _CounterPill extends StatelessWidget {
  final int quantity;
  final bool isOutOfStock;
  final ValueChanged<int> onUpdate;

  const _CounterPill({
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
          _ActionButton(
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
          _ActionButton(icon: Icons.add, onTap: () => onUpdate(1)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
