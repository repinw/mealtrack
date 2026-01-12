import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/features/sharing/presentation/sharing_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';

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

    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    const backgroundColor = AppTheme.primaryColor;
    const accentColor = AppTheme.secondaryColor;
    const textColor = AppTheme.white;
    const labelColor = Colors.grey;
    const highlightColor = AppTheme.accentColor;

    return AppBar(
      toolbarHeight: kToolbarHeight,
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: highlightColor,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
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
          icon: const Icon(Icons.settings, color: Colors.blue),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.stockValue,
                    style: const TextStyle(
                      fontSize: 12,
                      color: labelColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(stats.totalValue),
                    style: const TextStyle(
                      fontSize: 32,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: labelColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.purchases(stats.scanCount),
                        style: const TextStyle(color: labelColor, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      l10n.items(stats.articleCount),
                      style: const TextStyle(
                        color: highlightColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
