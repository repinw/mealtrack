import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String name;

  const CategoryIcon({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    const iconData = Icons.kitchen;
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: Icon(iconData, color: colorScheme.onSurfaceVariant, size: 22),
    );
  }
}
