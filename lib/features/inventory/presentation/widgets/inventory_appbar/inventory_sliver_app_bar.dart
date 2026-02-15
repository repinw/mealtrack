import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/presentation/widgets/feature_sliver_app_bar.dart';
import 'package:mealtrack/core/theme/feature_sliver_app_bar_defaults.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/inventory_header_content.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InventorySliverAppBar extends ConsumerWidget {
  const InventorySliverAppBar({
    super.key,
    required this.title,
    this.onOpenSharing,
    this.onOpenSettings,
  });

  final String title;
  final VoidCallback? onOpenSharing;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(inventoryStatsProvider);
    final headerTitle = l10n.inventory.isNotEmpty ? l10n.inventory : title;

    return FeatureSliverAppBar(
      expandedHeight: FeatureSliverAppBarDefaults.expandedHeight,
      collapsedHeight: FeatureSliverAppBarDefaults.collapsedHeight,
      toolbarHeight: 0,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
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
            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.10),
          ),
        ),
        child: Icon(
          Icons.receipt_long_outlined,
          size: 24,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.58),
        ),
      ),
      flexibleSpaceBuilder: (context, state) => InventoryHeaderContent(
        title: headerTitle,
        collapseProgress: state.collapseProgress,
        stockValueLabel: l10n.stockValue,
        purchasesStatLabel: l10n.purchasesLabel,
        itemsStatLabel: l10n.itemsLabel,
        purchasesLabel: l10n.purchases(stats.scanCount),
        itemsLabel: l10n.items(stats.articleCount),
        purchaseCount: stats.scanCount,
        totalValue: stats.totalValue,
        articleCount: stats.articleCount,
        onOpenSharing: onOpenSharing,
        onOpenSettings: onOpenSettings,
      ),
    );
  }
}
