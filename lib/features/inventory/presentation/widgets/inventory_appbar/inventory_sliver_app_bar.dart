import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/inventory_app_bar_actions.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/inventory_header_content.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InventorySliverAppBar extends ConsumerWidget {
  const InventorySliverAppBar({super.key, required this.title});

  final String title;

  static const double _expandedHeight = 160.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(inventoryStatsProvider);
    final topPadding = MediaQuery.paddingOf(context).top;
    final minHeight = kToolbarHeight + topPadding;
    final maxHeight = _expandedHeight + topPadding;
    final collapseRange = (maxHeight - minHeight).clamp(1.0, double.infinity);

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final collapseProgress = (constraints.scrollOffset / collapseRange)
            .clamp(0.0, 1.0);

        return SliverAppBar(
          pinned: true,
          expandedHeight: _expandedHeight,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          actions: [InventoryAppBarActions(collapseProgress: collapseProgress)],
          flexibleSpace: InventoryHeaderContent(
            title: title,
            collapseProgress: collapseProgress,
            trailingActionsSpace: InventoryAppBarActions.trailingActionsSpace(
              collapseProgress,
            ),
            stockValueLabel: l10n.stockValue,
            purchasesLabel: l10n.purchases(stats.scanCount),
            totalValue: stats.totalValue,
            articleCount: stats.articleCount,
          ),
        );
      },
    );
  }
}
