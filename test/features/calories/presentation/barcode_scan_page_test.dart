import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';
import 'package:mealtrack/features/calories/presentation/barcode_scan_page.dart';

void main() {
  group('BarcodeLookupResult', () {
    test('exposes single candidate helpers', () {
      final candidate = _candidate(code: '123');
      final result = BarcodeLookupResult(
        barcode: '123',
        candidates: [candidate],
      );

      expect(result.hasSingleCandidate, isTrue);
      expect(result.hasMultipleCandidates, isFalse);
      expect(result.hasNoCandidates, isFalse);
      expect(result.singleCandidate, same(candidate));
    });

    test('exposes no candidate helper', () {
      const result = BarcodeLookupResult(barcode: '123', candidates: []);

      expect(result.hasSingleCandidate, isFalse);
      expect(result.hasMultipleCandidates, isFalse);
      expect(result.hasNoCandidates, isTrue);
      expect(result.singleCandidate, isNull);
    });
  });

  group('BarcodeNoResultOverlay', () {
    testWidgets('calls all actions from buttons', (tester) async {
      var manualTapCount = 0;
      var ocrTapCount = 0;
      var retryTapCount = 0;

      await tester.pumpWidget(
        _testApp(
          child: BarcodeNoResultOverlay(
            barcode: '4001724819806',
            title: 'No products',
            manualLabel: 'Manual',
            ocrLabel: 'OCR',
            retryLabel: 'Retry',
            onManualEntry: () => manualTapCount++,
            onOcrEntry: () => ocrTapCount++,
            onRetryScan: () => retryTapCount++,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.edit_note_outlined));
      await tester.pump();
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(manualTapCount, 1);
      expect(ocrTapCount, 1);
      expect(retryTapCount, 1);
    });
  });

  group('BarcodeScanStatusCard', () {
    testWidgets('shows retry button when callback is provided', (tester) async {
      await tester.pumpWidget(
        _testApp(
          child: BarcodeScanStatusCard(
            headline: 'Scan',
            detail: 'Network error',
            isError: true,
            retryLabel: 'Retry',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
    });

    testWidgets('hides retry button when callback is null', (tester) async {
      await tester.pumpWidget(
        _testApp(
          child: const BarcodeScanStatusCard(
            headline: 'Scan',
            detail: '123456789',
            isError: false,
            retryLabel: 'Retry',
          ),
        ),
      );

      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Retry'), findsNothing);
    });
  });
}

Widget _testApp({required Widget child}) {
  return MaterialApp(home: Scaffold(body: child));
}

OffProductCandidate _candidate({required String code}) {
  return OffProductCandidate(
    code: code,
    name: 'Product',
    brand: null,
    quantityLabel: null,
    servingSizeLabel: null,
    imageUrl: null,
    per100: const NutritionPer100(
      kcal: 100,
      protein: 10,
      carbs: 20,
      fat: 5,
      sugar: 7,
      salt: 0.4,
      saturatedFat: null,
      polyunsaturatedFat: null,
      fiber: null,
    ),
    hasKcal: true,
    hasProtein: true,
    hasCarbs: true,
    hasFat: true,
    hasSugar: true,
    hasSalt: true,
    hasSaturatedFat: false,
    hasPolyunsaturatedFat: false,
    hasFiber: false,
    completenessScore: 1,
  );
}
