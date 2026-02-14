import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class CollapsedSummary extends StatelessWidget {
  const CollapsedSummary({
    super.key,
    required this.totalValue,
    required this.articleCount,
  });

  final double totalValue;
  final int articleCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
      name: 'EUR',
    ).format(totalValue);

    return Text(
      '$currency • ${l10n.items(articleCount)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}
