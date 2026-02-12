import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/collapsed_summary.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InventorySliverAppBar extends ConsumerWidget {
  const InventorySliverAppBar({
    super.key,
    required this.title,
    required this.onOpenSharing,
    required this.onOpenSettings,
  });

  final String title;
  final VoidCallback onOpenSharing;
  final VoidCallback onOpenSettings;

  static const double _expandedHeight = 160.0;
  static const double _summaryMinHeight = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(inventoryStatsProvider);
    final errorColor = Theme.of(context).colorScheme.error;
    final expandedSummary = RepaintBoundary(
      child: SummaryHeader(
        label: l10n.stockValue,
        totalValue: stats.totalValue,
        articleCount: stats.articleCount,
        secondaryInfo: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 16),
            const SizedBox(width: 4),
            Text(
              l10n.purchases(stats.scanCount),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
    final collapsedSummary = RepaintBoundary(
      child: CollapsedSummary(
        totalValue: stats.totalValue,
        articleCount: stats.articleCount,
      ),
    );

    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedHeight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      actions: [
        if (kDebugMode)
          IconButton(
            icon: Icon(Icons.delete_forever, color: errorColor),
            tooltip: l10n.debugHiveReset,
            onPressed: () async {
              await ref.read(fridgeItemsProvider.notifier).deleteAll();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.debugDataDeleted)));
              }
            },
          ),
        IconButton(
          onPressed: onOpenSharing,
          icon: const Icon(Icons.people_outline),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: l10n.settings,
          onPressed: onOpenSettings,
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final topPadding = MediaQuery.paddingOf(context).top;
          final minHeight = kToolbarHeight + topPadding;
          final maxHeight = _expandedHeight + topPadding;
          final range = (maxHeight - minHeight).clamp(1.0, double.infinity);
          final t = ((constraints.maxHeight - minHeight) / range).clamp(
            0.0,
            1.0,
          );
          final summaryHeight =
              (constraints.maxHeight - topPadding - kToolbarHeight)
                  .clamp(0.0, double.infinity)
                  .toDouble();
          final showExpandedSummary = summaryHeight >= _summaryMinHeight;
          final expandedOpacity = showExpandedSummary ? t : 0.0;
          final collapsedOpacity = showExpandedSummary ? 1 - t : 1.0;

          return SafeArea(
            bottom: false,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: expandedOpacity,
                  child: Column(
                    children: [
                      SizedBox(
                        height: kToolbarHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ClipRect(
                            child: showExpandedSummary
                                ? expandedSummary
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IgnorePointer(
                  ignoring: t > 0.1,
                  child: Opacity(
                    opacity: collapsedOpacity,
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 16,
                          end: 152,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: collapsedSummary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
