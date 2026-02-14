import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/domain/inventory_display_item.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ArchivedSectionHeader extends ConsumerWidget {
  const ArchivedSectionHeader({super.key, required this.section});

  final InventoryArchivedSectionItem section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () {
        ref.read(archivedItemsExpandedProvider.notifier).toggle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: Colors.grey.shade200,
        child: Row(
          children: [
            Icon(
              section.isExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Icon(Icons.archive_outlined, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              l10n.archivedCount(section.archivedReceiptCount),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
