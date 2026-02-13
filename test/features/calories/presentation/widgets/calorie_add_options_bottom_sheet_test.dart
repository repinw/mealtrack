import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/presentation/widgets/calorie_add_options_bottom_sheet.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';

void main() {
  group('CalorieAddOptionsBottomSheet', () {
    testWidgets('manual entry action is triggered and sheet closes', (
      tester,
    ) async {
      var manualCount = 0;
      var barcodeCount = 0;
      final l10n = AppLocalizationsDe();

      await tester.pumpWidget(
        _testHost(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CalorieAddOptionsBottomSheet.show(
                    context,
                    onManualEntry: () => manualCount++,
                    onBarcodeScan: () => barcodeCount++,
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.caloriesManualEntry), findsOneWidget);

      await tester.tap(find.text(l10n.caloriesManualEntry));
      await tester.pumpAndSettle();

      expect(manualCount, 1);
      expect(barcodeCount, 0);
      expect(find.text(l10n.caloriesManualEntry), findsNothing);
    });

    testWidgets('barcode scan action is triggered and sheet closes', (
      tester,
    ) async {
      var manualCount = 0;
      var barcodeCount = 0;
      final l10n = AppLocalizationsDe();

      await tester.pumpWidget(
        _testHost(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CalorieAddOptionsBottomSheet.show(
                    context,
                    onManualEntry: () => manualCount++,
                    onBarcodeScan: () => barcodeCount++,
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.caloriesBarcodeScan), findsOneWidget);

      await tester.tap(find.text(l10n.caloriesBarcodeScan));
      await tester.pumpAndSettle();

      expect(manualCount, 0);
      expect(barcodeCount, 1);
      expect(find.text(l10n.caloriesBarcodeScan), findsNothing);
    });
  });
}

Widget _testHost({required Widget child}) {
  return MaterialApp(
    locale: const Locale('de'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}
