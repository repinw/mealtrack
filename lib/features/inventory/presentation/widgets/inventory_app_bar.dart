import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/sharing/presentation/sharing_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';

class InventoryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const InventoryAppBar({super.key, required this.title});

  final String title;

  static const double _bottomHeight = 80.0;

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + _bottomHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(inventoryStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      toolbarHeight: kToolbarHeight,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        title.toUpperCase(),
        style: textTheme.titleSmall?.copyWith(fontSize: 14, letterSpacing: 1.2),
      ),
      actions: [
        if (kDebugMode)
          IconButton(
            icon: Icon(Icons.delete_forever, color: colorScheme.error),
            tooltip: l10n.debugHiveReset,
            onPressed: () async {
              await ref.read(fridgeItemsProvider.notifier).deleteAll();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.debugDataDeleted)));
              }
            },
          ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SharingPage()),
            );
          },
          icon: const Icon(Icons.people_outline),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: l10n.settings,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_bottomHeight),
        child: SummaryHeader(
          label: l10n.stockValue,
          totalValue: stats.totalValue,
          articleCount: stats.articleCount,
          secondaryInfo: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.purchases(stats.scanCount),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
