import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/theme/calories_theme.dart';
import 'package:mealtrack/features/calories/data/nutrition_ocr_repository.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class CalorieEntryEditPage extends ConsumerStatefulWidget {
  final String userId;
  final CalorieEntry? initialEntry;
  final Future<void> Function(CalorieEntry entry)? onSave;
  final bool autoScanNutritionOnOpen;

  const CalorieEntryEditPage({
    super.key,
    required this.userId,
    this.initialEntry,
    this.onSave,
    this.autoScanNutritionOnOpen = false,
  });

  @override
  ConsumerState<CalorieEntryEditPage> createState() =>
      _CalorieEntryEditPageState();
}

class _CalorieEntryEditPageState extends ConsumerState<CalorieEntryEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _sugarController = TextEditingController();
  final _saltController = TextEditingController();
  final _saturatedFatController = TextEditingController();
  final _polyunsaturatedFatController = TextEditingController();
  final _fiberController = TextEditingController();

  late MealType _mealType;
  late ConsumedUnit _consumedUnit;
  late DateTime _loggedAt;

  bool _saving = false;
  bool _scanningNutrition = false;
  bool _usedNutritionOcr = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    final forceCoreNutritionInput = _requiresCoreNutritionInputFor(entry);

    _nameController.text = entry?.productName ?? '';
    _amountController.text = _formatNumber(entry?.consumedAmount ?? 100);
    _kcalController.text = _initialRequiredNutritionValue(
      entry: entry,
      value: entry?.per100.kcal,
      forceInput: forceCoreNutritionInput,
    );
    _proteinController.text = _initialRequiredNutritionValue(
      entry: entry,
      value: entry?.per100.protein,
      forceInput: forceCoreNutritionInput,
    );
    _carbsController.text = _initialRequiredNutritionValue(
      entry: entry,
      value: entry?.per100.carbs,
      forceInput: forceCoreNutritionInput,
    );
    _fatController.text = _initialRequiredNutritionValue(
      entry: entry,
      value: entry?.per100.fat,
      forceInput: forceCoreNutritionInput,
    );
    _sugarController.text = _initialRequiredNutritionValue(
      entry: entry,
      value: entry?.per100.sugar,
      forceInput: forceCoreNutritionInput,
    );
    _saltController.text = _initialRequiredNutritionValue(
      entry: entry,
      value: entry?.per100.salt,
      forceInput: forceCoreNutritionInput,
    );
    _saturatedFatController.text = _initialOptionalNutritionValue(
      entry?.per100.saturatedFat,
    );
    _polyunsaturatedFatController.text = _initialOptionalNutritionValue(
      entry?.per100.polyunsaturatedFat,
    );
    _fiberController.text = _initialOptionalNutritionValue(entry?.per100.fiber);

    _mealType = entry?.mealType ?? MealType.defaultForDateTime(DateTime.now());
    _consumedUnit = entry?.consumedUnit ?? ConsumedUnit.grams;
    _loggedAt = entry?.loggedAt ?? DateTime.now();

    if (widget.autoScanNutritionOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_scanNutritionLabel());
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    _saltController.dispose();
    _saturatedFatController.dispose();
    _polyunsaturatedFatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final caloriesTheme = CaloriesTheme.of(context);
    final isEditing = widget.initialEntry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.caloriesEditEntryTitle : l10n.caloriesManualEntry,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: caloriesTheme.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.caloriesProductNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.caloriesProductNameRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: caloriesTheme.blockSpacing),
                DropdownButtonFormField<MealType>(
                  initialValue: _mealType,
                  decoration: InputDecoration(
                    labelText: l10n.caloriesMealLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: MealType.sectionOrder.map((mealType) {
                    return DropdownMenuItem<MealType>(
                      value: mealType,
                      child: Text(_mealLabel(l10n, mealType)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _mealType = value);
                  },
                ),
                SizedBox(height: caloriesTheme.blockSpacing),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        textInputAction: TextInputAction.next,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.caloriesAmountLabel,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final parsed = _parseDouble(value);
                          if (parsed == null || parsed <= 0) {
                            return l10n.caloriesAmountPositiveValidation;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: caloriesTheme.inlineSpacing),
                    Expanded(
                      child: DropdownButtonFormField<ConsumedUnit>(
                        initialValue: _consumedUnit,
                        decoration: InputDecoration(
                          labelText: l10n.caloriesUnitLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: ConsumedUnit.values.map((unit) {
                          return DropdownMenuItem<ConsumedUnit>(
                            value: unit,
                            child: Text(unit.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _consumedUnit = value);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: caloriesTheme.blockSpacing),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.caloriesNutritionPer100(
                          _consumedUnit == ConsumedUnit.grams ? 'g' : 'ml',
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (_showNutritionOcrAction)
                      TextButton.icon(
                        onPressed: _scanningNutrition
                            ? null
                            : _scanNutritionLabel,
                        icon: _scanningNutrition
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.camera_alt_outlined),
                        label: Text(
                          _scanningNutrition
                              ? l10n.loading
                              : l10n.caloriesScanNutritionFacts,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _kcalController,
                  label: l10n.caloriesEnergy,
                  invalidValueText: l10n.caloriesInvalidValue,
                  required: true,
                  requiredValueText: l10n.caloriesRequiredField,
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _fatController,
                  label: l10n.caloriesFat,
                  invalidValueText: l10n.caloriesInvalidValue,
                  required: true,
                  requiredValueText: l10n.caloriesRequiredField,
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _saturatedFatController,
                  label: l10n.caloriesSaturatedFat,
                  invalidValueText: l10n.caloriesInvalidValue,
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _polyunsaturatedFatController,
                  label: l10n.caloriesPolyunsaturatedFat,
                  invalidValueText: l10n.caloriesInvalidValue,
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _carbsController,
                  label: l10n.caloriesCarbs,
                  invalidValueText: l10n.caloriesInvalidValue,
                  required: true,
                  requiredValueText: l10n.caloriesRequiredField,
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _fiberController,
                  label: l10n.caloriesFiber,
                  invalidValueText: l10n.caloriesInvalidValue,
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _sugarController,
                  label: l10n.caloriesSugar,
                  invalidValueText: l10n.caloriesInvalidValue,
                  required: true,
                  requiredValueText: l10n.caloriesRequiredField,
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _proteinController,
                  label: l10n.caloriesProtein,
                  invalidValueText: l10n.caloriesInvalidValue,
                  required: true,
                  requiredValueText: l10n.caloriesRequiredField,
                ),
                SizedBox(height: caloriesTheme.inlineSpacing),
                _nutritionField(
                  controller: _saltController,
                  label: l10n.caloriesSalt,
                  invalidValueText: l10n.caloriesInvalidValue,
                  required: true,
                  requiredValueText: l10n.caloriesRequiredField,
                ),
                SizedBox(height: caloriesTheme.blockSpacing),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.caloriesDateTimeLabel),
                  subtitle: Text(
                    MaterialLocalizations.of(context).formatFullDate(_loggedAt),
                  ),
                  trailing: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatTimeOfDay(TimeOfDay.fromDateTime(_loggedAt)),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(l10n.caloriesDateButton),
                      ),
                    ),
                    SizedBox(width: caloriesTheme.inlineSpacing),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time_outlined),
                        label: Text(l10n.caloriesTimeButton),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: caloriesTheme.blockSpacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ),
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nutritionField({
    required TextEditingController controller,
    required String label,
    required String invalidValueText,
    bool required = false,
    String? requiredValueText,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (required && trimmed.isEmpty) {
          return requiredValueText ?? invalidValueText;
        }
        if (!required && trimmed.isEmpty) {
          return null;
        }

        final parsed = _parseDouble(value);
        if (parsed == null || parsed < 0) {
          return invalidValueText;
        }
        return null;
      },
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _loggedAt,
      firstDate: DateTime(now.year - 3),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _loggedAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _loggedAt.hour,
        _loggedAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_loggedAt),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _loggedAt = DateTime(
        _loggedAt.year,
        _loggedAt.month,
        _loggedAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _parseDouble(_amountController.text)!;
    final per100 = NutritionPer100(
      kcal: _parseDouble(_kcalController.text)!,
      protein: _parseDouble(_proteinController.text)!,
      carbs: _parseDouble(_carbsController.text)!,
      fat: _parseDouble(_fatController.text)!,
      sugar: _parseDouble(_sugarController.text)!,
      salt: _parseDouble(_saltController.text)!,
      saturatedFat: _parseDouble(_saturatedFatController.text),
      polyunsaturatedFat: _parseDouble(_polyunsaturatedFatController.text),
      fiber: _parseDouble(_fiberController.text),
    );

    final existing = widget.initialEntry;
    final entry = CalorieEntry.create(
      id: existing?.id ?? const Uuid().v4(),
      userId: widget.userId,
      productName: _nameController.text.trim(),
      source: _resolveSource(existing),
      mealType: _mealType,
      consumedAmount: amount,
      consumedUnit: _consumedUnit,
      per100: per100,
      loggedAt: _loggedAt,
      createdAt: existing?.createdAt,
      updatedAt: DateTime.now(),
      brand: existing?.brand,
      barcode: existing?.barcode,
      offProductRef: existing?.offProductRef,
    );

    if (!entry.isValid) return;

    setState(() => _saving = true);
    try {
      if (widget.onSave != null) {
        await widget.onSave!(entry);
      }
      if (mounted) {
        Navigator.of(context).pop(entry);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  CalorieEntrySource _resolveSource(CalorieEntry? existing) {
    if (!_usedNutritionOcr) {
      return existing?.source ?? CalorieEntrySource.manual;
    }
    final hasOffProductRef =
        (existing?.offProductRef?.trim().isNotEmpty ?? false);
    if (hasOffProductRef) return CalorieEntrySource.offBarcode;
    return CalorieEntrySource.ocrLabel;
  }

  bool get _showNutritionOcrAction {
    final entry = widget.initialEntry;
    if (entry == null) return true;
    if (entry.source == CalorieEntrySource.manual) return true;
    if (entry.source != CalorieEntrySource.offBarcode) return false;
    return entry.per100.kcal <= 0 ||
        entry.per100.sugar <= 0 ||
        entry.per100.protein <= 0 ||
        entry.per100.carbs <= 0 ||
        entry.per100.fat <= 0 ||
        entry.per100.salt <= 0;
  }

  Future<void> _scanNutritionLabel() async {
    if (_saving || _scanningNutrition) return;

    setState(() => _scanningNutrition = true);
    try {
      final result = await ref
          .read(nutritionOcrRepository)
          .analyzeNutritionLabelFromCamera();
      if (!mounted || result == null) return;

      setState(() {
        final parsedName = result.productName?.trim();
        if ((parsedName?.isNotEmpty ?? false) &&
            _nameController.text.trim().isEmpty) {
          _nameController.text = parsedName!;
        }

        if (result.hasKcal) {
          _kcalController.text = _formatNumber(result.per100.kcal);
        }
        if (result.hasProtein) {
          _proteinController.text = _formatNumber(result.per100.protein);
        }
        if (result.hasCarbs) {
          _carbsController.text = _formatNumber(result.per100.carbs);
        }
        if (result.hasFat) {
          _fatController.text = _formatNumber(result.per100.fat);
        }
        if (result.hasSugar) {
          _sugarController.text = _formatNumber(result.per100.sugar);
        }
        if (result.hasSalt) {
          _saltController.text = _formatNumber(result.per100.salt);
        }
        if (result.hasSaturatedFat) {
          _saturatedFatController.text = _formatNumber(
            result.per100.saturatedFat!,
          );
        }
        if (result.hasPolyunsaturatedFat) {
          _polyunsaturatedFatController.text = _formatNumber(
            result.per100.polyunsaturatedFat!,
          );
        }
        if (result.hasFiber) {
          _fiberController.text = _formatNumber(result.per100.fiber!);
        }
        _usedNutritionOcr = true;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.errorOccurred}$e')));
    } finally {
      if (mounted) {
        setState(() => _scanningNutrition = false);
      }
    }
  }

  double? _parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  String _formatNumber(double value) {
    final decimals = value % 1 == 0 ? 0 : 1;
    return value.toStringAsFixed(decimals);
  }

  bool _requiresCoreNutritionInputFor(CalorieEntry? entry) {
    if (entry == null) return false;
    if (entry.source != CalorieEntrySource.offBarcode) return false;
    final hasNoOffReference = entry.offProductRef?.trim().isEmpty ?? true;
    if (!hasNoOffReference) return false;

    return entry.per100.kcal == 0 &&
        entry.per100.sugar == 0 &&
        entry.per100.protein == 0 &&
        entry.per100.carbs == 0 &&
        entry.per100.fat == 0 &&
        entry.per100.salt == 0;
  }

  String _initialRequiredNutritionValue({
    required CalorieEntry? entry,
    required double? value,
    required bool forceInput,
  }) {
    if (forceInput) return '';
    if (value == null) return '';
    if (entry == null) return '';

    final isOffBarcodeDraft = entry.source == CalorieEntrySource.offBarcode;
    if (isOffBarcodeDraft && value <= 0) {
      return '';
    }
    return _formatNumber(value);
  }

  String _initialOptionalNutritionValue(double? value) {
    if (value == null) return '';
    return _formatNumber(value);
  }

  String _mealLabel(AppLocalizations l10n, MealType mealType) {
    return switch (mealType) {
      MealType.breakfast => l10n.caloriesMealBreakfast,
      MealType.lunch => l10n.caloriesMealLunch,
      MealType.dinner => l10n.caloriesMealDinner,
      MealType.snack => l10n.caloriesMealSnack,
    };
  }
}
