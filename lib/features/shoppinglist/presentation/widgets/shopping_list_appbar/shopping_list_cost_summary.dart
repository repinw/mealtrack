import 'package:flutter/material.dart';
import 'package:mealtrack/core/formatting/currency_formatter_cache.dart';

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
