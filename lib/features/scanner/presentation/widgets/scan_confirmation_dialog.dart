import 'package:flutter/material.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ScanConfirmationDialog extends StatelessWidget {
  const ScanConfirmationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ScanConfirmationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    return AlertDialog(
      title: Text(l10n.scanReceiptDialogTitle),
      content: Text(l10n.scanReceiptDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.yes),
        ),
      ],
    );
  }
}
