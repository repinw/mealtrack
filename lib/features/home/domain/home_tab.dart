import 'package:flutter/material.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

enum HomeTab {
  inventory,
  shoppingList,
  calories,
  statistics;

  String getLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case HomeTab.inventory:
        return l10n.inventory;
      case HomeTab.shoppingList:
        return l10n.shoppinglist;
      case HomeTab.calories:
        return l10n.calories;
      case HomeTab.statistics:
        return l10n.statistics;
    }
  }

  IconData getIcon(bool isSelected) {
    switch (this) {
      case HomeTab.inventory:
        return isSelected ? Icons.inventory_2 : Icons.inventory_2_outlined;
      case HomeTab.shoppingList:
        return isSelected ? Icons.shopping_bag : Icons.shopping_bag_outlined;
      case HomeTab.calories:
        return isSelected
            ? Icons.local_fire_department
            : Icons.local_fire_department_outlined;
      case HomeTab.statistics:
        return isSelected ? Icons.bar_chart : Icons.bar_chart_outlined;
    }
  }

  bool get isFeatureAvailable {
    switch (this) {
      case HomeTab.inventory:
      case HomeTab.shoppingList:
      case HomeTab.calories:
        return true;
      case HomeTab.statistics:
        return false;
    }
  }
}
