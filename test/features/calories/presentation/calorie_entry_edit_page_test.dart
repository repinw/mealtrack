import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/presentation/calorie_entry_edit_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';

void main() {
  group('CalorieEntryEditPage', () {
    testWidgets(
      'requires kcal/fat/carbs/sugar/protein/salt for no-result barcode draft',
      (tester) async {
        final l10n = AppLocalizationsDe();
        var saveCalled = false;

        await tester.pumpWidget(
          _buildSubject(
            initialEntry: _noResultBarcodeDraft(),
            onSave: (entry) async {
              saveCalled = true;
            },
          ),
        );

        final saveButton = find.widgetWithText(ElevatedButton, l10n.save);
        await tester.ensureVisible(saveButton);
        await tester.tap(find.widgetWithText(ElevatedButton, l10n.save));
        await tester.pumpAndSettle();

        expect(saveCalled, isFalse);
        expect(find.text(l10n.caloriesRequiredField), findsNWidgets(6));
      },
    );

    testWidgets('saves when all required nutrient fields are filled', (
      tester,
    ) async {
      final l10n = AppLocalizationsDe();
      CalorieEntry? savedEntry;
      final neverComplete = Completer<void>();

      await tester.pumpWidget(
        _buildSubject(
          initialEntry: _noResultBarcodeDraft(),
          onSave: (entry) async {
            savedEntry = entry;
            return neverComplete.future;
          },
        ),
      );

      await tester.enterText(_editableFieldAt(2), '222');
      await tester.enterText(_editableFieldAt(3), '8');
      await tester.enterText(_editableFieldAt(6), '27');
      await tester.enterText(_editableFieldAt(8), '4');
      await tester.enterText(_editableFieldAt(9), '11');
      await tester.enterText(_editableFieldAt(10), '0.9');

      final saveButton = find.widgetWithText(ElevatedButton, l10n.save);
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(savedEntry, isNotNull);
      expect(savedEntry!.per100.kcal, 222);
      expect(savedEntry!.per100.protein, 11);
      expect(savedEntry!.per100.carbs, 27);
      expect(savedEntry!.per100.fat, 8);
      expect(savedEntry!.per100.sugar, 4);
      expect(savedEntry!.per100.salt, 0.9);
      expect(savedEntry!.per100.saturatedFat, isNull);
      expect(savedEntry!.per100.fiber, isNull);
      expect(savedEntry!.source, CalorieEntrySource.offBarcode);
      expect(find.text(l10n.caloriesRequiredField), findsNothing);
    });
  });
}

Widget _buildSubject({
  required CalorieEntry initialEntry,
  required Future<void> Function(CalorieEntry entry) onSave,
}) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CalorieEntryEditPage(
        userId: 'user-1',
        initialEntry: initialEntry,
        onSave: onSave,
      ),
    ),
  );
}

CalorieEntry _noResultBarcodeDraft() {
  final now = DateTime(2026, 1, 1, 12, 0);
  return CalorieEntry.create(
    id: 'draft-1',
    userId: 'user-1',
    productName: '1234567890123',
    source: CalorieEntrySource.offBarcode,
    mealType: MealType.lunch,
    consumedAmount: 100,
    consumedUnit: ConsumedUnit.grams,
    per100: NutritionPer100.zero,
    loggedAt: now,
    createdAt: now,
    updatedAt: now,
    barcode: '1234567890123',
    offProductRef: null,
  );
}

Finder _editableFieldAt(int index) {
  return find.byType(EditableText).at(index);
}
