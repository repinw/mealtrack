import 'package:flutter/material.dart';
import 'package:mealtrack/core/formatting/currency_formatter_cache.dart';
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
  static const double _minimumSummaryHeight = 64.0;
  static const double _expandedTitleFadeFactor = 1.55;
  static const double _expandedSummaryFadeFactor = 1.45;
  static const double _collapsedStatsStart = 0.18;
  static const double _collapsedStatsSpan = 0.82;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalizedProgress = collapseProgress.clamp(0.0, 1.0).toDouble();
    final expandedTitleOpacity = _expandedTitleOpacity(normalizedProgress);
    final expandedHeaderOpacity = _expandedHeaderOpacity(normalizedProgress);
    final collapsedMetricsOpacity = _collapsedMetricsOpacity(
      normalizedProgress,
    );
    final collapsedBottomPadding = _collapsedBottomPadding(
      collapsedMetricsOpacity,
    );
    final formattedTotalValue = CurrencyFormatterCache.formatEur(
      context,
      totalValue,
    );
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.4,
    );

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: expandedTitleOpacity,
              child: SizedBox(
                height: kToolbarHeight,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: expandedTitleOpacity,
                          child: Text(
                            title.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                        ),
                      ),
                      InventoryAppBarActions(
                        collapseProgress: collapseProgress,
                        onOpenSharing: onOpenSharing,
                        onOpenSettings: onOpenSettings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hasRoomForExpandedSummary =
                    constraints.maxHeight >= _minimumSummaryHeight;
                final useCompactSummary = constraints.maxHeight < 104;
                final hideMetaLine = constraints.maxHeight < 84;
                final expandedBottomPadding = (constraints.maxHeight * 0.06)
                    .clamp(0.0, 6.0)
                    .toDouble();
                return IgnorePointer(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasRoomForExpandedSummary)
                        Opacity(
                          opacity: expandedHeaderOpacity,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: InventoryExpandedSummary(
                              key: const ValueKey('inventory-expanded-summary'),
                              stockValueLabel: stockValueLabel,
                              totalValue: formattedTotalValue,
                              purchasesLabel: purchasesLabel,
                              itemsLabel: itemsLabel,
                              compact: useCompactSummary,
                              hideMetaLine: hideMetaLine,
                              bottomPadding: expandedBottomPadding,
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Opacity(
                          opacity: collapsedMetricsOpacity,
                          child: InventoryCollapsedStatsRow(
                            key: const ValueKey('inventory-collapsed-stats'),
                            stockValueLabel: stockValueLabel,
                            stockValue: formattedTotalValue,
                            purchasesStatLabel: purchasesStatLabel,
                            purchaseCount: purchaseCount,
                            itemsStatLabel: itemsStatLabel,
                            articleCount: articleCount,
                            bottomPadding: collapsedBottomPadding,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _expandedTitleOpacity(double progress) {
    return (1 - (progress * _expandedTitleFadeFactor)).clamp(0.0, 1.0);
  }

  double _expandedHeaderOpacity(double progress) {
    return (1 - (progress * _expandedSummaryFadeFactor)).clamp(0.0, 1.0);
  }

  double _collapsedMetricsOpacity(double progress) {
    return ((progress - _collapsedStatsStart) / _collapsedStatsSpan).clamp(
      0.0,
      1.0,
    );
  }

  double _collapsedBottomPadding(double collapsedMetricsOpacity) {
    return 2 + (collapsedMetricsOpacity * 3);
  }
}
