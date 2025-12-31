import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class InventoryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const InventoryAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(fridgeItemsProvider);

    double totalValue = 0;
    int scanCount = 0;
    int articleCount = 0;

    if (itemsAsync.hasValue) {
      final items = itemsAsync.value!;
      final activeItems = items.where((i) => i.quantity > 0).toList();

      totalValue = activeItems.fold(
        0.0,
        (sum, i) => sum + (i.unitPrice * i.quantity),
      );
      scanCount = activeItems
          .map((e) => e.receiptId)
          .where((e) => e != null && e.isNotEmpty)
          .toSet()
          .length;
      articleCount = activeItems.fold(0, (sum, i) => sum + i.quantity);
    }

    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    const backgroundColor = AppTheme.primaryColor;
    const accentColor = AppTheme.secondaryColor;
    const textColor = AppTheme.white;
    const labelColor = Colors.grey;
    const highlightColor = AppTheme.accentColor;

    return AppBar(
      toolbarHeight: 140,
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
            tooltip: AppLocalizations.debugHiveReset,
            onPressed: () async {
              await ref.read(fridgeItemsProvider.notifier).deleteAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppLocalizations.debugDataDeleted),
                  ),
                );
              }
            },
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
                  const Text(
                    'VORRATSWERT',
                    style: TextStyle(
                      fontSize: 12,
                      color: labelColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(totalValue),
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
                        AppLocalizations.purchases(scanCount),
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
                      AppLocalizations.items(articleCount),
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
