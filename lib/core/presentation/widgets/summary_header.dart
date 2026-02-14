import 'package:flutter/material.dart';
import 'package:mealtrack/core/formatting/currency_formatter_cache.dart';
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
  final Color? foregroundColor;
  final Color? secondaryForegroundColor;
  final Color? badgeBackgroundColor;
  final Color? badgeBorderColor;

  const SummaryHeader({
    super.key,
    required this.label,
    required this.totalValue,
    required this.articleCount,
    this.secondaryInfo,
    this.foregroundColor,
    this.secondaryForegroundColor,
    this.badgeBackgroundColor,
    this.badgeBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final resolvedForegroundColor =
        foregroundColor ?? textTheme.bodyLarge?.color ?? colorScheme.onSurface;
    final resolvedSecondaryForegroundColor =
        secondaryForegroundColor ?? colorScheme.onSurfaceVariant;
    final summaryLabelStyle = textTheme.labelSmall?.copyWith(
      letterSpacing: 0.5,
      height: 1.0,
      color: resolvedSecondaryForegroundColor,
    );
    final summaryValueStyle = textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      height: 1.0,
      color: resolvedForegroundColor,
    );
    final summaryItemCountStyle = textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: resolvedForegroundColor,
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
                    CurrencyFormatterCache.formatEur(context, totalValue),
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
                      color: badgeBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: badgeBorderColor == null
                          ? null
                          : Border.all(color: badgeBorderColor!),
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
