import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_display_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class InventoryGroupHeader extends ConsumerWidget {
  const InventoryGroupHeader({super.key, required this.header});

  final InventoryHeaderItem header;

  Color get _headerColor =>
      header.isArchived ? Colors.grey.shade100 : const Color(0xFFF4F7F9);

  Color get _headerTextColor =>
      header.isArchived ? Colors.grey.shade500 : const Color(0xFF455A64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {
        ref
            .read(collapsedReceiptGroupsProvider.notifier)
            .toggle(header.receiptId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: _headerColor,
        child: Row(
          children: [
            Icon(
              header.isCollapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.blueGrey,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${DateFormat('dd.MM.yyyy').format(header.entryDate)} • ${header.storeName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _headerTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (header.isArchived)
              _HeaderActionButton(
                onTap: () => ref
                    .read(fridgeItemsProvider.notifier)
                    .unarchiveReceipt(header.receiptId),
                icon: Icons.unarchive_outlined,
                label: l10n.unarchive,
                baseColor: Colors.green,
              )
            else if (header.isFullyConsumed)
              _HeaderActionButton(
                onTap: () => ref
                    .read(fridgeItemsProvider.notifier)
                    .archiveReceipt(header.receiptId),
                icon: Icons.archive_outlined,
                label: l10n.archive,
                baseColor: Colors.orange,
              ),
            _ItemCountBadge(itemCount: header.itemCount, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.baseColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final MaterialColor baseColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: baseColor.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: baseColor.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: baseColor.shade800),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: baseColor.shade800,
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
  const _ItemCountBadge({required this.itemCount, required this.l10n});

  final int itemCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        l10n.entries(itemCount),
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      ),
    );
  }
}
