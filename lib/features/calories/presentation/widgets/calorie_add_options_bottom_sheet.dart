import 'package:flutter/material.dart';
import 'package:mealtrack/core/theme/calories_theme.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class CalorieAddOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onManualEntry;
  final VoidCallback onBarcodeScan;

  const CalorieAddOptionsBottomSheet({
    super.key,
    required this.onManualEntry,
    required this.onBarcodeScan,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onManualEntry,
    required VoidCallback onBarcodeScan,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CalorieAddOptionsBottomSheet(
        onManualEntry: onManualEntry,
        onBarcodeScan: onBarcodeScan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final caloriesTheme = CaloriesTheme.of(context);

    return SafeArea(
      child: Padding(
        padding: caloriesTheme.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectOption,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: caloriesTheme.blockSpacing),
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: Text(l10n.caloriesManualEntry),
              onTap: () {
                Navigator.of(context).pop();
                onManualEntry();
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(l10n.caloriesBarcodeScan),
              onTap: () {
                Navigator.of(context).pop();
                onBarcodeScan();
              },
            ),
            SizedBox(height: caloriesTheme.inlineSpacing),
          ],
        ),
      ),
    );
  }
}
