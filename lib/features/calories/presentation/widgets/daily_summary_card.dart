import 'package:flutter/material.dart';
import 'package:mealtrack/core/theme/calories_theme.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class DailySummaryCard extends StatelessWidget {
  final DateTime date;
  final double totalKcal;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  DailySummaryCard({
    super.key,
    DateTime? date,
    this.totalKcal = 0,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatGrams = 0,
  }) : date = date ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final caloriesTheme = CaloriesTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final formattedDate = _dateLabel(context, date);
    final dateStyle = theme.textTheme.titleMedium?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w700,
    );
    final kcalValueStyle = theme.textTheme.displaySmall?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w800,
      height: 1.05,
    );
    final kcalLabelStyle = theme.textTheme.titleSmall?.copyWith(
      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
      letterSpacing: 0.2,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: caloriesTheme.cardRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: caloriesTheme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(formattedDate, style: dateStyle)),
                DailySummaryBadge(
                  icon: Icons.local_fire_department_outlined,
                  label: l10n.calories,
                ),
              ],
            ),
            SizedBox(height: caloriesTheme.sectionSpacing),
            Text(_format(totalKcal), style: kcalValueStyle),
            Text(l10n.calories, style: kcalLabelStyle),
            SizedBox(height: caloriesTheme.blockSpacing),
            Row(
              children: [
                Expanded(
                  child: DailySummaryMacroTile(
                    label: l10n.caloriesProtein,
                    value: '${_format(proteinGrams)} g',
                    color: colorScheme.tertiaryContainer,
                  ),
                ),
                SizedBox(width: caloriesTheme.inlineSpacing),
                Expanded(
                  child: DailySummaryMacroTile(
                    label: l10n.caloriesCarbs,
                    value: '${_format(carbsGrams)} g',
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
                SizedBox(width: caloriesTheme.inlineSpacing),
                Expanded(
                  child: DailySummaryMacroTile(
                    label: l10n.caloriesFat,
                    value: '${_format(fatGrams)} g',
                    color: colorScheme.secondary.withValues(alpha: 0.16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _format(double value) {
    final decimals = value % 1 == 0 ? 0 : 1;
    return value.toStringAsFixed(decimals);
  }

  String _dateLabel(BuildContext context, DateTime value) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final isToday =
        now.year == value.year &&
        now.month == value.month &&
        now.day == value.day;
    if (isToday) return l10n.caloriesToday;
    return MaterialLocalizations.of(context).formatMediumDate(value);
  }
}

class DailySummaryBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const DailySummaryBadge({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.12),
        border: Border.all(
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class DailySummaryMacroTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const DailySummaryMacroTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
