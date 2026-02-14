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
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Row(
            children: HomeTab.values
                .map((tab) => Expanded(child: _buildNavItem(context, tab)))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, HomeTab tab) {
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
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Opacity(
            opacity: 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.getIcon(false), color: Colors.grey),
                Text(
                  tab.getLabel(context),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
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
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () => onDestinationSelected(tab),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.getIcon(isSelected),
              color: isSelected ? primaryColor : Colors.grey,
            ),
            Text(
              tab.getLabel(context),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey,
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
