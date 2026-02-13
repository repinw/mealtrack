import 'package:flutter/material.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scanned_item_row.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ReceiptColumnHeaders extends StatelessWidget {
  const ReceiptColumnHeaders({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final headerStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 9,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: ScannedItemRow.colQtyWidth,
            child: Text(
              l10n.amountAbbr,
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          Expanded(child: Text(l10n.brandDescription, style: headerStyle)),
          const SizedBox(width: 12),
          SizedBox(
            width: ScannedItemRow.colWeightWidth,
            child: Text(
              l10n.weight,
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: ScannedItemRow.colPriceWidth,
            child: Padding(
              padding: const EdgeInsets.only(right: 28.0),
              child: Text(
                l10n.price,
                textAlign: TextAlign.right,
                style: headerStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
