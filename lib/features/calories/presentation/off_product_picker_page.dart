import 'package:flutter/material.dart';
import 'package:mealtrack/core/theme/calories_theme.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class OffProductPickerPage extends StatefulWidget {
  final String barcode;
  final List<OffProductCandidate> candidates;

  const OffProductPickerPage({
    super.key,
    required this.barcode,
    required this.candidates,
  });

  static Future<OffProductCandidate?> open(
    BuildContext context, {
    required String barcode,
    required List<OffProductCandidate> candidates,
  }) {
    return Navigator.of(context).push<OffProductCandidate>(
      MaterialPageRoute(
        builder: (_) =>
            OffProductPickerPage(barcode: barcode, candidates: candidates),
      ),
    );
  }

  @override
  State<OffProductPickerPage> createState() => _OffProductPickerPageState();
}

class _OffProductPickerPageState extends State<OffProductPickerPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final caloriesTheme = CaloriesTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectOption)),
      body: SafeArea(
        child: Padding(
          padding: caloriesTheme.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OffProductPickerHeader(barcode: widget.barcode),
              SizedBox(height: caloriesTheme.inlineSpacing),
              Expanded(
                child: widget.candidates.isEmpty
                    ? Center(child: Text(l10n.noAvailableProducts))
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          final candidate = widget.candidates[index];
                          return OffProductCandidateCard(
                            candidate: candidate,
                            selected: index == _selectedIndex,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          );
                        },
                        separatorBuilder: (_, _) =>
                            SizedBox(height: caloriesTheme.inlineSpacing),
                        itemCount: widget.candidates.length,
                      ),
              ),
              SizedBox(height: caloriesTheme.inlineSpacing),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  SizedBox(width: caloriesTheme.inlineSpacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.candidates.isEmpty ? null : _onContinue,
                      child: Text(l10n.proceed),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    final selected = widget.candidates[_selectedIndex];
    Navigator.of(context).pop(selected);
  }
}

class OffProductPickerHeader extends StatelessWidget {
  final String barcode;

  const OffProductPickerHeader({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(barcode, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Open Food Facts', style: textTheme.bodySmall),
      ],
    );
  }
}

class OffProductCandidateCard extends StatelessWidget {
  final OffProductCandidate candidate;
  final bool selected;
  final VoidCallback onTap;

  const OffProductCandidateCard({
    super.key,
    required this.candidate,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        candidate.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if ((candidate.brand ?? '').isNotEmpty)
                  Text(
                    candidate.brand!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if ((candidate.quantityLabel ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      candidate.quantityLabel!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                OffProductNutritionRow(
                  energyLabel:
                      '${_formatValue(candidate.per100.kcal)} ${l10n.caloriesEnergy}',
                  fatLabel:
                      '${_formatValue(candidate.per100.fat)} ${l10n.caloriesFat}',
                  carbsLabel:
                      '${_formatValue(candidate.per100.carbs)} ${l10n.caloriesCarbs}',
                  sugarLabel:
                      '${_formatValue(candidate.per100.sugar)} ${l10n.caloriesSugar}',
                  proteinLabel:
                      '${_formatValue(candidate.per100.protein)} ${l10n.caloriesProtein}',
                  saltLabel:
                      '${_formatValue(candidate.per100.salt)} ${l10n.caloriesSalt}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatValue(double value) {
    final decimals = value % 1 == 0 ? 0 : 1;
    return value.toStringAsFixed(decimals);
  }
}

class OffProductNutritionRow extends StatelessWidget {
  final String energyLabel;
  final String carbsLabel;
  final String fatLabel;
  final String sugarLabel;
  final String proteinLabel;
  final String saltLabel;

  const OffProductNutritionRow({
    super.key,
    required this.energyLabel,
    required this.carbsLabel,
    required this.fatLabel,
    required this.sugarLabel,
    required this.proteinLabel,
    required this.saltLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OffProductNutritionChip(label: energyLabel, style: theme.labelLarge),
        OffProductNutritionChip(label: fatLabel, style: theme.labelLarge),
        OffProductNutritionChip(label: carbsLabel, style: theme.labelLarge),
        OffProductNutritionChip(label: sugarLabel, style: theme.labelLarge),
        OffProductNutritionChip(label: proteinLabel, style: theme.labelLarge),
        OffProductNutritionChip(label: saltLabel, style: theme.labelLarge),
      ],
    );
  }
}

class OffProductNutritionChip extends StatelessWidget {
  final String label;
  final TextStyle? style;

  const OffProductNutritionChip({super.key, required this.label, this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(label, style: style),
    );
  }
}
