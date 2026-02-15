import 'package:flutter/material.dart';
import 'package:mealtrack/core/formatting/currency_formatter_cache.dart';
import 'package:mealtrack/core/presentation/widgets/feature_sliver_header_content.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_appbar/shopping_list_collapsed_stats_row.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_appbar/shopping_list_cost_summary.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ShoppingListHeaderContent extends StatelessWidget {
  const ShoppingListHeaderContent({
    super.key,
    required this.title,
    required this.collapseProgress,
    required this.approximateCostLabel,
    required this.totalValue,
    required this.articleCount,
    required this.clearListTooltip,
    required this.onClearList,
  });

  final String title;
  final double collapseProgress;
  final String approximateCostLabel;
  final double totalValue;
  final int articleCount;
  final String clearListTooltip;
  final VoidCallback onClearList;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                key: const ValueKey('shopping-expanded-title-opacity'),
                opacity: state.titleOpacity,
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
            ),
            IconButton(
              tooltip: clearListTooltip,
              icon: const Icon(Icons.delete_sweep),
              onPressed: onClearList,
            ),
          ],
        ),
      ),
      bodyBuilder: (context, state) => Stack(
        fit: StackFit.expand,
        children: [
          if (state.hasRoomForExpandedSummary)
            Opacity(
              key: const ValueKey('shopping-expanded-summary-opacity'),
              opacity: state.expandedContentOpacity,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ShoppingListCostSummary(
                  label: approximateCostLabel,
                  totalValue: totalValue,
                  itemCountLabel: l10n.items(articleCount),
                  compact: state.useCompactSummary,
                  hideMetaLine: state.hideMetaLine,
                  bottomPadding: state.expandedBottomPadding,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              key: const ValueKey('shopping-collapsed-stats-opacity'),
              opacity: state.collapsedContentOpacity,
              child: ShoppingListCollapsedStatsRow(
                costLabel: approximateCostLabel,
                costValue: CurrencyFormatterCache.formatEur(
                  context,
                  totalValue,
                ),
                itemsLabel: l10n.itemsLabel,
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
