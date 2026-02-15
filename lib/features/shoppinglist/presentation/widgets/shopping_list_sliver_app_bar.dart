import 'package:flutter/material.dart';
import 'package:mealtrack/core/formatting/currency_formatter_cache.dart';
import 'package:mealtrack/core/presentation/widgets/feature_sliver_app_bar.dart';
import 'package:mealtrack/core/presentation/widgets/feature_sliver_header_content.dart';
import 'package:mealtrack/core/theme/feature_sliver_app_bar_defaults.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ShoppingListSliverAppBar extends StatelessWidget {
  const ShoppingListSliverAppBar({
    super.key,
    required this.title,
    required this.approximateCostLabel,
    required this.totalValue,
    required this.articleCount,
    required this.clearListTooltip,
    required this.onClearList,
  });

  final String title;
  final String approximateCostLabel;
  final double totalValue;
  final int articleCount;
  final String clearListTooltip;
  final VoidCallback onClearList;

  @override
  Widget build(BuildContext context) {
    return FeatureSliverAppBar(
      expandedHeight: FeatureSliverAppBarDefaults.expandedHeight,
      collapsedHeight: FeatureSliverAppBarDefaults.collapsedHeight,
      toolbarHeight: 0,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      backgroundAlignment: const Alignment(0.84, 0.48),
      backgroundRotationRadians: 0,
      backgroundMaxOpacity: 0.22,
      backgroundBuilder: (context, state) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(
            context,
          ).colorScheme.onPrimaryContainer.withValues(alpha: 0.08),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 24,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.58),
        ),
      ),
      flexibleSpaceBuilder: (context, state) => ShoppingListHeaderContent(
        title: title,
        collapseProgress: state.collapseProgress,
        approximateCostLabel: approximateCostLabel,
        totalValue: totalValue,
        articleCount: articleCount,
        clearListTooltip: clearListTooltip,
        onClearList: onClearList,
      ),
    );
  }
}

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

class ShoppingListCostSummary extends StatelessWidget {
  const ShoppingListCostSummary({
    super.key,
    required this.label,
    required this.totalValue,
    required this.itemCountLabel,
    required this.compact,
    required this.hideMetaLine,
    required this.bottomPadding,
  });

  final String label;
  final double totalValue;
  final String itemCountLabel;
  final bool compact;
  final bool hideMetaLine;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryTextColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurface.withValues(alpha: 0.72);
    final labelStyle =
        (compact ? theme.textTheme.labelMedium : theme.textTheme.labelLarge)
            ?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
              letterSpacing: compact ? 0.5 : 0.8,
              height: compact ? 1.1 : null,
            );
    final valueStyle =
        (compact
                ? theme.textTheme.headlineMedium
                : theme.textTheme.displaySmall)
            ?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w800,
              height: 1.0,
            );
    final metaStyle =
        (compact ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)
            ?.copyWith(
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
              height: compact ? 1.2 : null,
            );
    final valueTopSpacing = compact ? 0.0 : 1.5;
    final metaTopSpacing = compact ? 1.5 : 3.0;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 18, end: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
          SizedBox(height: valueTopSpacing),
          Text(
            CurrencyFormatterCache.formatEur(context, totalValue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
          if (!hideMetaLine) ...[
            SizedBox(height: metaTopSpacing),
            Text(
              itemCountLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: metaStyle,
            ),
          ],
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}

class ShoppingListCollapsedStatsRow extends StatelessWidget {
  const ShoppingListCollapsedStatsRow({
    super.key,
    required this.costLabel,
    required this.costValue,
    required this.itemsLabel,
    required this.articleCount,
    required this.bottomPadding,
  });

  final String costLabel;
  final String costValue;
  final String itemsLabel;
  final int articleCount;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            Expanded(
              child: ShoppingListCollapsedStatColumn(
                label: costLabel.toUpperCase(),
                value: costValue,
              ),
            ),
            Expanded(
              child: ShoppingListCollapsedStatColumn(
                label: itemsLabel.toUpperCase(),
                value: '$articleCount',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShoppingListCollapsedStatColumn extends StatelessWidget {
  const ShoppingListCollapsedStatColumn({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.92),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
