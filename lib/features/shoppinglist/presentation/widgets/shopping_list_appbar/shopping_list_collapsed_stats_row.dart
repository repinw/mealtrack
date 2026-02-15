import 'package:flutter/material.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_appbar/shopping_list_collapsed_stat_column.dart';

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
