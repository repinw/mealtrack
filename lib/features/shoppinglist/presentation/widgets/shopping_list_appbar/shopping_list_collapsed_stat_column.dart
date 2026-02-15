import 'package:flutter/material.dart';

class ShoppingListCollapsedStatColumn extends StatelessWidget {
  const ShoppingListCollapsedStatColumn({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.92),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
