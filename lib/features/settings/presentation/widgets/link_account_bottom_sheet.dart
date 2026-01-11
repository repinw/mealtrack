import 'package:flutter/material.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.linkAccount,
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
              label: Text(l10n.createNewAccount),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onUseExistingAccount();
              },
              icon: const Icon(Icons.login),
              label: Text(l10n.useExistingAccount),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
