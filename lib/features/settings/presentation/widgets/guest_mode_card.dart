import 'package:flutter/material.dart';
import 'package:mealtrack/core/l10n/l10n.dart';

class GuestModeCard extends StatelessWidget {
  const GuestModeCard({super.key, required this.onLinkAccount});

  final VoidCallback onLinkAccount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    L10n.guestMode,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              L10n.guestModeDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onLinkAccount,
                icon: const Icon(Icons.link),
                label: const Text(L10n.linkAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
