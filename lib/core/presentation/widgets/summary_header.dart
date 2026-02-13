import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class SummaryHeader extends StatelessWidget {
  final String label;
  final double totalValue;
  final int articleCount;
  final Widget? secondaryInfo;

  const SummaryHeader({
    super.key,
    required this.label,
    required this.totalValue,
    required this.articleCount,
    this.secondaryInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
      name: 'EUR',
    );
    final summaryLabelStyle = textTheme.labelSmall?.copyWith(
      letterSpacing: 0.5,
      height: 1.0,
    );
    final summaryValueStyle = textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      height: 1.0,
    );
    final summaryItemCountStyle = textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: summaryLabelStyle,
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(totalValue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: summaryValueStyle,
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (secondaryInfo != null) ...[
                secondaryInfo!,
                const SizedBox(height: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.items(articleCount),
                  style: summaryItemCountStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
