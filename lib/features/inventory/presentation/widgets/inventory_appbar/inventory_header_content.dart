import 'package:flutter/material.dart';
import 'package:mealtrack/core/formatting/currency_formatter_cache.dart';
import 'package:mealtrack/core/presentation/widgets/feature_sliver_header_content.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/inventory_app_bar_actions.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/inventory_collapsed_stats_row.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/inventory_expanded_summary.dart';

class InventoryHeaderContent extends StatelessWidget {
  const InventoryHeaderContent({
    super.key,
    required this.title,
    required this.collapseProgress,
    required this.stockValueLabel,
    required this.purchasesStatLabel,
    required this.itemsStatLabel,
    required this.purchasesLabel,
    required this.itemsLabel,
    required this.purchaseCount,
    required this.totalValue,
    required this.articleCount,
    this.onOpenSharing,
    this.onOpenSettings,
  });

  final String title;
  final double collapseProgress;
  final String stockValueLabel;
  final String purchasesStatLabel;
  final String itemsStatLabel;
  final String purchasesLabel;
  final String itemsLabel;
  final int purchaseCount;
  final double totalValue;
  final int articleCount;
  final VoidCallback? onOpenSharing;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedTotalValue = CurrencyFormatterCache.formatEur(
      context,
      totalValue,
    );
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.4,
    );

    return FeatureSliverHeaderContent(
      collapseProgress: collapseProgress,
      titleBuilder: (context, state) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
        child: Row(
          children: [
            Expanded(
              child: Opacity(
                opacity: state.titleOpacity,
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
            ),
            InventoryAppBarActions(
              collapseProgress: state.collapseProgress,
              onOpenSharing: onOpenSharing,
              onOpenSettings: onOpenSettings,
            ),
          ],
        ),
      ),
      bodyBuilder: (context, state) => Stack(
        fit: StackFit.expand,
        children: [
          if (state.hasRoomForExpandedSummary)
            Opacity(
              opacity: state.expandedContentOpacity,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: InventoryExpandedSummary(
                  key: const ValueKey('inventory-expanded-summary'),
                  stockValueLabel: stockValueLabel,
                  totalValue: formattedTotalValue,
                  purchasesLabel: purchasesLabel,
                  itemsLabel: itemsLabel,
                  compact: state.useCompactSummary,
                  hideMetaLine: state.hideMetaLine,
                  bottomPadding: state.expandedBottomPadding,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: state.collapsedContentOpacity,
              child: InventoryCollapsedStatsRow(
                key: const ValueKey('inventory-collapsed-stats'),
                stockValueLabel: stockValueLabel,
                stockValue: formattedTotalValue,
                purchasesStatLabel: purchasesStatLabel,
                purchaseCount: purchaseCount,
                itemsStatLabel: itemsStatLabel,
                articleCount: articleCount,
                bottomPadding: state.collapsedBottomPadding,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
