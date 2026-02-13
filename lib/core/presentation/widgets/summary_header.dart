import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class SummaryHeader extends StatelessWidget {
  static const double _defaultBottomPadding = 20.0;
  static const double _regularItemVerticalPadding = 6.0;
  static const double _compactItemVerticalPadding = 4.0;
  static const double _regularSecondarySpacing = 8.0;
  static const double _compactSecondarySpacing = 4.0;
  static const double _minimumRightColumnHeight = 55.0;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight =
            constraints.hasBoundedHeight && constraints.maxHeight < 76;
        final secondarySpacing = isCompactHeight
            ? _compactSecondarySpacing
            : _regularSecondarySpacing;
        final itemVerticalPadding = isCompactHeight
            ? _compactItemVerticalPadding
            : _regularItemVerticalPadding;

        var bottomPadding = _defaultBottomPadding;
        if (constraints.hasBoundedHeight) {
          final maxBottomPadding =
              constraints.maxHeight - _minimumRightColumnHeight;
          bottomPadding = maxBottomPadding
              .clamp(0.0, _defaultBottomPadding)
              .toDouble();
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
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
                    SizedBox(height: secondarySpacing),
                  ],
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: itemVerticalPadding,
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
      },
    );
  }
}
