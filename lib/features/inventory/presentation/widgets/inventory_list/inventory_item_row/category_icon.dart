import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String name;

  const CategoryIcon({super.key, required this.name});

  static const IconData _fallbackIcon = Icons.kitchen_outlined;

  static const Map<String, IconData> _categoryMap = {
    'banana': Icons.eco_outlined,
    'basilikum': Icons.spa_outlined,
    'bier': Icons.sports_bar_outlined,
    'brot': Icons.bakery_dining_outlined,
    'brötchen': Icons.bakery_dining_outlined,
    'champignon': Icons.forest_outlined,
    'chips': Icons.cookie_outlined,
    'dip': Icons.ramen_dining_outlined,
    'eier': Icons.egg_outlined,
    'energydrink': Icons.bolt_outlined,
    'fertiggericht': Icons.lunch_dining_outlined,
    'fruchtgummi': Icons.icecream_outlined,
    'hackfleisch': Icons.set_meal_outlined,
    'hähnchen': Icons.restaurant_outlined,
    'hähnchenleber': Icons.restaurant_outlined,
    'bacon': Icons.set_meal_outlined,
    'fischstäbchen': Icons.set_meal_outlined,
    'milch': Icons.local_drink_outlined,
    'mozzarella': Icons.breakfast_dining_outlined,
    'müsliriegel': Icons.lunch_dining_outlined,
    'musliriegel': Icons.lunch_dining_outlined,
    'nudelsalat': Icons.ramen_dining_outlined,
    'pfeffer': Icons.spa_outlined,
    'pommes': Icons.fastfood_outlined,
    'quark': Icons.breakfast_dining_outlined,
    'sahne': Icons.breakfast_dining_outlined,
    'salami': Icons.set_meal_outlined,
    'salat': Icons.eco_outlined,
    'saure sahne': Icons.breakfast_dining_outlined,
    'saure_sahne': Icons.breakfast_dining_outlined,
    'schinken': Icons.set_meal_outlined,
    'schmelzkäse': Icons.breakfast_dining_outlined,
    'schmelzkaese': Icons.breakfast_dining_outlined,
    'schokolade': Icons.cookie_outlined,
    'sonnenblumenkerne': Icons.spa_outlined,
    'streichfett': Icons.breakfast_dining_outlined,
    'tomate': Icons.eco_outlined,
    'wasser': Icons.water_drop_outlined,
    'wurst': Icons.set_meal_outlined,
    'zucchini': Icons.eco_outlined,
  };

  IconData _resolveIcon(String rawName) {
    final normalized = rawName.trim().toLowerCase();
    if (normalized.isEmpty) return _fallbackIcon;
    return _categoryMap[normalized] ?? _fallbackIcon;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = _resolveIcon(name);

    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.secondaryContainer,
      child: Icon(iconData, color: colorScheme.onSecondaryContainer, size: 22),
    );
  }
}
