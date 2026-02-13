import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_display_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class InventoryGroupHeader extends ConsumerWidget {
  const InventoryGroupHeader({super.key, required this.header});

  final InventoryHeaderItem header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        ref
            .read(collapsedReceiptGroupsProvider.notifier)
            .toggle(header.receiptId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              header.isCollapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 20,
            ),
            Expanded(
              child: Text(
                '${standardDateFormat.format(header.entryDate)} • ${header.storeName}',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
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
              )
            else if (header.isFullyConsumed)
              _HeaderActionButton(
                onTap: () => ref
                    .read(fridgeItemsProvider.notifier)
                    .archiveReceipt(header.receiptId),
                icon: Icons.archive_outlined,
                label: l10n.archive,
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
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
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
    return Text(
      l10n.entries(itemCount),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
