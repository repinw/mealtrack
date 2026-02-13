import 'package:flutter/material.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/collapsed_summary.dart';

class InventoryHeaderContent extends StatelessWidget {
  const InventoryHeaderContent({
    super.key,
    required this.title,
    required this.collapseProgress,
    required this.trailingActionsSpace,
    required this.stockValueLabel,
    required this.purchasesLabel,
    required this.totalValue,
    required this.articleCount,
  });

  final String title;
  final double collapseProgress;
  final double trailingActionsSpace;
  final String stockValueLabel;
  final String purchasesLabel;
  final double totalValue;
  final int articleCount;
  static const double _minimumSummaryHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final expandedTitleOpacity = (1 - collapseProgress).clamp(0.0, 1.0);
    final expandedHeaderOpacity = (1 - (collapseProgress * 1.6)).clamp(
      0.0,
      1.0,
    );
    final collapsedSummaryOpacity = ((collapseProgress - 0.25) / 0.75).clamp(
      0.0,
      1.0,
    );

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: 16,
                end: trailingActionsSpace,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    Opacity(
                      opacity: expandedTitleOpacity,
                      child: Text(
                        title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: collapsedSummaryOpacity,
                      child: CollapsedSummary(
                        totalValue: totalValue,
                        articleCount: articleCount,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hasRoomForSummary =
                    constraints.maxHeight >= _minimumSummaryHeight;

                if (!hasRoomForSummary || expandedHeaderOpacity <= 0) {
                  return const SizedBox.shrink();
                }

                return IgnorePointer(
                  child: Opacity(
                    opacity: expandedHeaderOpacity,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SummaryHeader(
                        label: stockValueLabel,
                        totalValue: totalValue,
                        articleCount: articleCount,
                        secondaryInfo: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              purchasesLabel,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
