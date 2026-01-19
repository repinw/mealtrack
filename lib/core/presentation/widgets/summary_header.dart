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
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

    const labelColor = Colors.grey;
    const textColor = AppTheme.white;
    const accentColor = AppTheme.secondaryColor;
    const highlightColor = AppTheme.accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left Side: Label and Total Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(totalValue),
                style: const TextStyle(
                  fontSize: 32,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Right Side: Secondary Info and Item Count Pill
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
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  l10n.items(articleCount),
                  style: const TextStyle(
                    color: highlightColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
