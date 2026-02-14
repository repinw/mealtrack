import 'package:flutter/material.dart';
import 'package:mealtrack/features/home/domain/home_tab.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class HomeNavigationBar extends StatelessWidget {
  final HomeTab currentTab;
  final ValueChanged<HomeTab> onDestinationSelected;

  const HomeNavigationBar({
    super.key,
    required this.currentTab,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: HomeTab.values
                .map((tab) => _buildNavItem(context, tab))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, HomeTab tab) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!tab.isFeatureAvailable) {
      return InkWell(
        onTap: () {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.featureInProgress),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Opacity(
            opacity: 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.getIcon(false), color: colorScheme.onSurfaceVariant),
                Text(
                  tab.getLabel(context),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isSelected = currentTab == tab;
    return InkWell(
      onTap: () => onDestinationSelected(tab),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.getIcon(isSelected),
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            Text(
              tab.getLabel(context),
              style: TextStyle(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
