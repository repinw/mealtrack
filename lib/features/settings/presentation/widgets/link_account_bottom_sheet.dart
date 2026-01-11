import 'package:flutter/material.dart';
import 'package:mealtrack/core/l10n/l10n.dart';

class LinkAccountBottomSheet extends StatelessWidget {
  const LinkAccountBottomSheet({
    super.key,
    required this.onNewAccount,
    required this.onUseExistingAccount,
  });

  final VoidCallback onNewAccount;
  final VoidCallback onUseExistingAccount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              L10n.linkAccount,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onNewAccount();
              },
              icon: const Icon(Icons.person_add),
              label: const Text(L10n.createNewAccount),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onUseExistingAccount();
              },
              icon: const Icon(Icons.login),
              label: const Text(L10n.useExistingAccount),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
