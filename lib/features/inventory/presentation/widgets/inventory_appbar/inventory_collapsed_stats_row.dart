import 'package:flutter/material.dart';

class InventoryCollapsedStatsRow extends StatelessWidget {
  const InventoryCollapsedStatsRow({
    super.key,
    required this.stockValueLabel,
    required this.stockValue,
    required this.purchasesStatLabel,
    required this.purchaseCount,
    required this.itemsStatLabel,
    required this.articleCount,
    required this.bottomPadding,
  });

  final String stockValueLabel;
  final String stockValue;
  final String purchasesStatLabel;
  final int purchaseCount;
  final String itemsStatLabel;
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
              child: InventoryCollapsedStatColumn(
                label: stockValueLabel.toUpperCase(),
                value: stockValue,
              ),
            ),
            Expanded(
              child: InventoryCollapsedStatColumn(
                label: purchasesStatLabel.toUpperCase(),
                value: '$purchaseCount',
              ),
            ),
            Expanded(
              child: InventoryCollapsedStatColumn(
                label: itemsStatLabel.toUpperCase(),
                value: '$articleCount',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryCollapsedStatColumn extends StatelessWidget {
  const InventoryCollapsedStatColumn({
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
