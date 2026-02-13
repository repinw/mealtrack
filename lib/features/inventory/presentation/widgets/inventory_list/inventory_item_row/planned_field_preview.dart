import 'package:flutter/material.dart';

class PlannedFieldPreview extends StatelessWidget {
  const PlannedFieldPreview({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
