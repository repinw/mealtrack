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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final headerColor = header.isArchived
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainer;
    final headerTextColor = header.isArchived
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;

    return InkWell(
      onTap: () {
        ref
            .read(collapsedReceiptGroupsProvider.notifier)
            .toggle(header.receiptId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: headerColor,
        child: Row(
          children: [
            Icon(
              header.isCollapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            Expanded(
              child: Text(
                '${standardDateFormat.format(header.entryDate)} • ${header.storeName}',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: headerTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (header.isArchived)
              InventoryHeaderActionButton(
                onTap: () => ref
                    .read(fridgeItemsProvider.notifier)
                    .unarchiveReceipt(header.receiptId),
                icon: Icons.unarchive_outlined,
                label: l10n.unarchive,
                backgroundColor: colorScheme.primaryContainer,
                borderColor: colorScheme.outlineVariant,
                foregroundColor: colorScheme.onPrimaryContainer,
              )
            else if (header.isFullyConsumed)
              InventoryHeaderActionButton(
                onTap: () => ref
                    .read(fridgeItemsProvider.notifier)
                    .archiveReceipt(header.receiptId),
                icon: Icons.archive_outlined,
                label: l10n.archive,
                backgroundColor: colorScheme.secondaryContainer,
                borderColor: colorScheme.outlineVariant,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
            InventoryItemCountBadge(itemCount: header.itemCount, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class InventoryHeaderActionButton extends StatelessWidget {
  const InventoryHeaderActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: foregroundColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InventoryItemCountBadge extends StatelessWidget {
  const InventoryItemCountBadge({
    super.key,
    required this.itemCount,
    required this.l10n,
  });

  final int itemCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        l10n.entries(itemCount),
        style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
