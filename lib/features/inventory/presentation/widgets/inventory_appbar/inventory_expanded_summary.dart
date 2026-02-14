import 'package:flutter/material.dart';

class InventoryExpandedSummary extends StatelessWidget {
  const InventoryExpandedSummary({
    super.key,
    required this.stockValueLabel,
    required this.totalValue,
    required this.purchasesLabel,
    required this.itemsLabel,
    required this.compact,
    required this.hideMetaLine,
    required this.bottomPadding,
  });

  final String stockValueLabel;
  final String totalValue;
  final String purchasesLabel;
  final String itemsLabel;
  final bool compact;
  final bool hideMetaLine;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryTextColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurface.withValues(alpha: 0.72);
    final summaryLabelStyle =
        (compact ? theme.textTheme.labelMedium : theme.textTheme.labelLarge)
            ?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
              letterSpacing: compact ? 0.5 : 0.8,
              height: compact ? 1.1 : null,
            );
    final summaryValueStyle =
        (compact
                ? theme.textTheme.headlineMedium
                : theme.textTheme.displaySmall)
            ?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w800,
              height: 1.0,
            );
    final summaryMetaStyle =
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
            stockValueLabel.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: summaryLabelStyle,
          ),
          SizedBox(height: valueTopSpacing),
          Text(
            totalValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: summaryValueStyle,
          ),
          if (!hideMetaLine) ...[
            SizedBox(height: metaTopSpacing),
            Text(
              '$purchasesLabel • $itemsLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: summaryMetaStyle,
            ),
          ],
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}
