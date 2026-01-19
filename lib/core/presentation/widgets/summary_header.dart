import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class SummaryHeader extends StatelessWidget {
  final String label;
  final double totalValue;
  final int articleCount;
  final Widget? secondaryInfo;

  static const _labelColor = Colors.grey;
  static const _textColor = AppTheme.white;
  static const _accentColor = AppTheme.secondaryColor;
  static const _highlightColor = AppTheme.accentColor;

  static const _labelStyle = TextStyle(
    fontSize: 12,
    color: _labelColor,
    letterSpacing: 0.5,
  );

  static const _totalValueStyle = TextStyle(
    fontSize: 32,
    color: _textColor,
    fontWeight: FontWeight.bold,
  );

  static const _itemCountStyle = TextStyle(
    color: _highlightColor,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

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
              Text(label, style: _labelStyle),
              const SizedBox(height: 4),
              Text(currencyFormat.format(totalValue), style: _totalValueStyle),
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
                  color: _accentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.items(articleCount),
                  style: _itemCountStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
