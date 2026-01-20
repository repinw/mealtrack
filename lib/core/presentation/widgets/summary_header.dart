import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
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
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
      name: 'EUR',
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
              Text(label, style: AppTheme.summaryLabelStyle),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(totalValue),
                style: AppTheme.summaryValueStyle,
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
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.items(articleCount),
                  style: AppTheme.summaryItemCountStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
