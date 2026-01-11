import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/core/l10n/l10n.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';

/// A header widget for grouping inventory items by receipt.
class InventoryGroupHeader extends ConsumerWidget {
  const InventoryGroupHeader({super.key, required this.header});

  final InventoryHeaderItem header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: const Color(0xFFF4F7F9),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 8),
          Text(
            '${DateFormat('dd.MM.yyyy').format(header.entryDate)} • ${header.storeName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF455A64),
            ),
          ),
          const Spacer(),
          if (header.isFullyConsumed)
            _ArchiveButton(receiptId: header.receiptId),
          _ItemCountBadge(itemCount: header.itemCount),
        ],
      ),
    );
  }
}

class _ArchiveButton extends ConsumerWidget {
  const _ArchiveButton({required this.receiptId});

  final String receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          ref
              .read(fridgeItemsProvider.notifier)
              .deleteItemsByReceipt(receiptId);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.archive_outlined,
                size: 14,
                color: Colors.orange.shade800,
              ),
              const SizedBox(width: 4),
              Text(
                L10n.archive,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCountBadge extends StatelessWidget {
  const _ItemCountBadge({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        L10n.entries(itemCount),
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      ),
    );
  }
}
