import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/theme/calories_theme.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/provider/calorie_log_provider.dart';
import 'package:mealtrack/features/calories/provider/calorie_settings_provider.dart';
import 'package:mealtrack/features/calories/presentation/widgets/meal_section_card.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class CaloriesPage extends ConsumerWidget {
  const CaloriesPage({super.key});
  static const double _scrollBottomSpacing = 144;
  static const double _summaryExpandedHeight = 232;
  static const double _summaryCollapsedHeight = 78;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final caloriesTheme = CaloriesTheme.of(context);
    final selectedDay = ref.watch(calorieDaySelection);
    final summary = ref.watch(calorieDaySummary);
    final groupedEntries = ref.watch(calorieEntriesByMeal);
    final entriesState = ref.watch(calorieEntriesForSelectedDay);
    final goalProgress = ref.watch(calorieGoalProgress);
    final daySelection = ref.read(calorieDaySelection.notifier);
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    if (entriesState.isLoading && !entriesState.hasValue) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.calories)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (entriesState.hasError && !entriesState.hasValue) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.calories)),
        body: Center(child: Text('${l10n.errorOccurred}${entriesState.error}')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: _summaryExpandedHeight,
            collapsedHeight: _summaryCollapsedHeight,
            backgroundColor: Theme.of(context).colorScheme.surface,
            flexibleSpace: CaloriesSummarySliverHeader(
              expandedHeight: _summaryExpandedHeight,
              collapsedHeight: _summaryCollapsedHeight,
              dayLabel: _dayLabel(context, selectedDay),
              caloriesLabel: l10n.calories,
              totalKcal: summary.totalKcal,
              dailyGoalKcal: goalProgress.hasGoal
                  ? goalProgress.settings.dailyKcalGoal
                  : null,
              totalProtein: summary.totalProtein,
              totalCarbs: summary.totalCarbs,
              totalFat: summary.totalFat,
              onPreviousDay: daySelection.previousDay,
              onNextDay: daySelection.nextDay,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              caloriesTheme.pagePadding.left,
              caloriesTheme.inlineSpacing,
              caloriesTheme.pagePadding.right,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!goalProgress.hasGoal)
                  OutlinedButton.icon(
                    onPressed: () => _showSetGoalDialog(context, ref),
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Tagesziel setzen'),
                  )
                else
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: caloriesTheme.cardRadius,
                    ),
                    child: Padding(
                      padding: caloriesTheme.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tagesziel: ${goalProgress.settings.dailyKcalGoal?.toStringAsFixed(0) ?? '0'} ${l10n.calories}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: caloriesTheme.inlineSpacing),
                          LinearProgressIndicator(
                            value: goalProgress.progress01 ?? 0,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          SizedBox(height: caloriesTheme.inlineSpacing),
                          Text(
                            'Verbleibend: ${(goalProgress.remainingKcal ?? 0).toStringAsFixed(0)} ${l10n.calories}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: caloriesTheme.inlineSpacing),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () =>
                                    _showSetGoalDialog(context, ref),
                                child: const Text('Ziel bearbeiten'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await ref
                                      .read(calorieGoalMutations)
                                      .clearGoal();
                                },
                                child: const Text('Ziel löschen'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: caloriesTheme.blockSpacing),
                ...MealType.sectionOrder.map((mealType) {
                  final entries =
                      groupedEntries[mealType] ?? const <CalorieEntry>[];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: caloriesTheme.sectionSpacing,
                    ),
                    child: MealSectionCard(
                      title: _mealLabel(l10n, mealType),
                      emptyLabel: l10n.caloriesNoEntriesYet,
                      content: entries.isEmpty
                          ? null
                          : Column(
                              children: entries.map((entry) {
                                return CalorieMealEntryTile(
                                  entry: entry,
                                  onDelete: () =>
                                      _confirmDeleteEntry(context, ref, entry),
                                );
                              }).toList(),
                            ),
                    ),
                  );
                }),
                SizedBox(height: _scrollBottomSpacing + bottomSafeArea),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _mealLabel(AppLocalizations l10n, MealType mealType) {
    return switch (mealType) {
      MealType.breakfast => l10n.caloriesMealBreakfast,
      MealType.lunch => l10n.caloriesMealLunch,
      MealType.dinner => l10n.caloriesMealDinner,
      MealType.snack => l10n.caloriesMealSnack,
    };
  }

  String _dayLabel(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    if (isToday) return AppLocalizations.of(context)!.caloriesToday;
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Future<void> _showSetGoalDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final currentGoal = ref.read(calorieGoalProgress).settings.dailyKcalGoal;
    if (currentGoal != null && currentGoal > 0) {
      controller.text = currentGoal.toStringAsFixed(0);
    }
    final l10n = AppLocalizations.of(context)!;

    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${l10n.calories} Ziel'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${l10n.calories} / Tag',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final parsed = _parseDouble(controller.text);
                if (parsed == null || parsed <= 0) return;
                Navigator.of(dialogContext).pop(parsed);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (value == null || value <= 0) return;
    await ref.read(calorieGoalMutations).setDailyGoal(value);
  }

  Future<void> _confirmDeleteEntry(
    BuildContext context,
    WidgetRef ref,
    CalorieEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteItemConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(calorieLogMutations).delete(entry.id);
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }
}

class CaloriesSummarySliverHeader extends StatelessWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final String dayLabel;
  final String caloriesLabel;
  final double totalKcal;
  final double? dailyGoalKcal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  const CaloriesSummarySliverHeader({
    super.key,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.dayLabel,
    required this.caloriesLabel,
    required this.totalKcal,
    this.dailyGoalKcal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final topPadding = MediaQuery.of(context).padding.top;
        final minHeight = collapsedHeight + topPadding;
        final currentHeight = constraints.biggest.height;
        final denominator = expandedHeight - collapsedHeight;
        final expandedT = denominator <= 0
            ? 0.0
            : ((currentHeight - minHeight) / denominator).clamp(0.0, 1.0);

        final expandedOpacity = Curves.easeOut.transform(expandedT);
        final collapsedOpacity = 1 - Curves.easeIn.transform(expandedT);

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer.withValues(alpha: 0.96),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                ignoring: expandedOpacity < 0.1,
                child: Opacity(
                  opacity: expandedOpacity,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: onPreviousDay,
                                icon: const Icon(Icons.chevron_left),
                              ),
                              Expanded(
                                child: Text(
                                  dayLabel,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: onNextDay,
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            _format(totalKcal),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onPrimaryContainer,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            _kcalProgressLabel(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.82,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              CaloriesSummaryMacroPill(
                                icon: Icons.egg_alt,
                                label: '${_format(totalProtein)}g',
                              ),
                              CaloriesSummaryMacroPill(
                                icon: Icons.bakery_dining,
                                label: '${_format(totalCarbs)}g',
                              ),
                              CaloriesSummaryMacroPill(
                                icon: Icons.water_drop,
                                label: '${_format(totalFat)}g',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Opacity(
                  opacity: collapsedOpacity,
                  child: SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: collapsedHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      dayLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    _kcalProgressLabel(),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  CaloriesSummaryCompactMacro(
                                    icon: Icons.egg_alt,
                                    value: '${_format(totalProtein)}g',
                                  ),
                                  CaloriesSummaryCompactMacro(
                                    icon: Icons.bakery_dining,
                                    value: '${_format(totalCarbs)}g',
                                  ),
                                  CaloriesSummaryCompactMacro(
                                    icon: Icons.water_drop,
                                    value: '${_format(totalFat)}g',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _format(double value) {
    final decimals = value % 1 == 0 ? 0 : 1;
    return value.toStringAsFixed(decimals);
  }

  String _kcalProgressLabel() {
    final goal = dailyGoalKcal;
    if (goal == null || goal <= 0) {
      return '${_format(totalKcal)} $caloriesLabel';
    }
    return '${_format(totalKcal)} / ${_format(goal)} $caloriesLabel';
  }
}

class CaloriesSummaryMacroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const CaloriesSummaryMacroPill({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.12),
        border: Border.all(
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CaloriesSummaryCompactMacro extends StatelessWidget {
  final IconData icon;
  final String value;

  const CaloriesSummaryCompactMacro({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CalorieMealEntryTile extends StatelessWidget {
  final CalorieEntry entry;
  final VoidCallback? onDelete;

  const CalorieMealEntryTile({super.key, required this.entry, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final caloriesTheme = CaloriesTheme.of(context);
    final sourceLabel = _sourceLabel(entry.source);

    return Container(
      margin: EdgeInsets.only(bottom: caloriesTheme.inlineSpacing),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.productName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.totalKcal.toStringAsFixed(0)} ${l10n.calories}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 2),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.delete,
                ),
              ],
            ],
          ),
          if ((entry.brand?.trim().isNotEmpty ?? false)) ...[
            const SizedBox(height: 2),
            Text(
              entry.brand!.trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CalorieMealEntryChip(
                label: MaterialLocalizations.of(
                  context,
                ).formatTimeOfDay(TimeOfDay.fromDateTime(entry.loggedAt)),
              ),
              CalorieMealEntryChip(
                label:
                    '${_format(entry.consumedAmount)} ${entry.consumedUnit.value}',
              ),
              CalorieMealEntryChip(label: sourceLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.caloriesProtein} ${_format(entry.totalProtein)} g • '
            '${l10n.caloriesCarbs} ${_format(entry.totalCarbs)} g • '
            '${l10n.caloriesFat} ${_format(entry.totalFat)} g',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _format(double value) {
    final decimals = value % 1 == 0 ? 0 : 1;
    return value.toStringAsFixed(decimals);
  }

  String _sourceLabel(CalorieEntrySource source) {
    return switch (source) {
      CalorieEntrySource.manual => 'Manual',
      CalorieEntrySource.offBarcode => 'Barcode',
      CalorieEntrySource.ocrLabel => 'OCR',
    };
  }
}

class CalorieMealEntryChip extends StatelessWidget {
  final String label;

  const CalorieMealEntryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
