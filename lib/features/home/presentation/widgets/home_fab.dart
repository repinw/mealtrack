import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/calories/data/calorie_log_repository.dart';
import 'package:mealtrack/features/calories/presentation/calorie_entry_edit_page.dart';
import 'package:mealtrack/features/calories/presentation/barcode_scan_page.dart';
import 'package:mealtrack/features/calories/presentation/off_product_picker_page.dart';
import 'package:mealtrack/features/calories/presentation/widgets/calorie_add_options_bottom_sheet.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';
import 'package:mealtrack/features/home/domain/home_tab.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scan_options_bottom_sheet.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/add_shopping_item_dialog.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class HomeFab extends ConsumerWidget {
  final HomeTab currentTab;

  const HomeFab({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        onPressed: () => _onPressed(context, ref),
        child: _buildIcon(context, ref),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    switch (currentTab) {
      case HomeTab.inventory:
        ScanOptionsBottomSheet.show(context);
        break;
      case HomeTab.shoppingList:
        showDialog(
          context: context,
          builder: (context) => const AddShoppingItemDialog(),
        );
        break;
      case HomeTab.calories:
        await _onCaloriesPressed(context, ref);
        break;
      default:
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addItemNotImplemented)));
    }
  }

  Future<void> _onCaloriesPressed(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorOccurred)));
      return;
    }

    await CalorieAddOptionsBottomSheet.show(
      context,
      onManualEntry: () {
        _openCalorieEntryEditor(context, ref, userId: user.uid);
      },
      onBarcodeScan: () {
        unawaited(_startBarcodeFlow(context, ref, user.uid));
      },
    );
  }

  Future<void> _startBarcodeFlow(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final lookupResult = await BarcodeScanPage.open(context);
    if (!context.mounted || lookupResult == null) return;

    OffProductCandidate? selectedCandidate;
    var autoScanNutritionOnOpen = false;
    if (lookupResult.hasSingleCandidate) {
      selectedCandidate = lookupResult.singleCandidate;
    } else if (lookupResult.hasMultipleCandidates) {
      selectedCandidate = await OffProductPickerPage.open(
        context,
        barcode: lookupResult.barcode,
        candidates: lookupResult.candidates,
      );
      if (!context.mounted || selectedCandidate == null) return;
    } else {
      final noResultAction = lookupResult.noResultAction;
      if (noResultAction == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noAvailableProducts)));
      }
      autoScanNutritionOnOpen =
          noResultAction == BarcodeNoResultAction.ocrFromCamera;
    }

    if (!context.mounted) return;
    final initialEntry = _buildOffPrefilledEntry(
      userId: userId,
      barcode: lookupResult.barcode,
      candidate: selectedCandidate,
    );
    _openCalorieEntryEditor(
      context,
      ref,
      userId: userId,
      initialEntry: initialEntry,
      autoScanNutritionOnOpen: autoScanNutritionOnOpen,
    );
  }

  void _openCalorieEntryEditor(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    CalorieEntry? initialEntry,
    bool autoScanNutritionOnOpen = false,
  }) {
    final repository = ref.read(calorieLogRepository);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CalorieEntryEditPage(
          userId: userId,
          initialEntry: initialEntry,
          onSave: repository.saveEntry,
          autoScanNutritionOnOpen: autoScanNutritionOnOpen,
        ),
      ),
    );
  }

  CalorieEntry _buildOffPrefilledEntry({
    required String userId,
    required String barcode,
    OffProductCandidate? candidate,
  }) {
    final now = DateTime.now();
    return CalorieEntry.create(
      id: 'draft_${now.microsecondsSinceEpoch}',
      userId: userId,
      productName: candidate?.name ?? barcode,
      source: CalorieEntrySource.offBarcode,
      mealType: MealType.defaultForDateTime(now),
      consumedAmount: 100,
      consumedUnit: ConsumedUnit.grams,
      per100: candidate?.per100 ?? NutritionPer100.zero,
      loggedAt: now,
      createdAt: now,
      updatedAt: now,
      brand: candidate?.brand,
      barcode: barcode,
      offProductRef: candidate == null ? null : 'off:${candidate.code}',
    );
  }

  Widget _buildIcon(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerViewModelProvider);
    final isInventoryLoading =
        currentTab == HomeTab.inventory && scannerState.isLoading;

    if (isInventoryLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    final IconData icon = currentTab == HomeTab.inventory
        ? Icons.center_focus_weak
        : Icons.add;

    return Icon(icon, color: Colors.white);
  }
}
