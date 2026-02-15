import 'package:flutter/material.dart';
import 'package:mealtrack/core/presentation/widgets/feature_sliver_app_bar.dart';
import 'package:mealtrack/core/theme/feature_sliver_app_bar_defaults.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_appbar/shopping_list_header_content.dart';

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
