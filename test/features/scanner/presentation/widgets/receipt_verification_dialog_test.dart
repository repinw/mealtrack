import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_verification_dialog.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

Widget buildLocalizedMaterialApp({required Widget home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  late TextEditingController merchantController;
  late TextEditingController dateController;

  setUp(() {
    merchantController = TextEditingController(text: 'Test Merchant');
    dateController = TextEditingController(text: '01.01.2025');
  });

  tearDown(() {
    merchantController.dispose();
    dateController.dispose();
  });

  group('ReceiptVerificationDialog Widget Test', () {
    testWidgets('Renders correctly with initial values', (tester) async {
      await tester.pumpWidget(
        buildLocalizedMaterialApp(
          home: Scaffold(
            body: ReceiptVerificationDialog(
              merchantController: merchantController,
              dateController: dateController,
              onConfirm: () {},
              onCancel: () {},
              onDateTap: () {},
              onMerchantChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Merchant'), findsOneWidget);
      expect(find.text('01.01.2025'), findsOneWidget);
      expect(find.text('Bestätigen'), findsOneWidget);
      expect(find.text('Abbrechen'), findsOneWidget);
    });

    testWidgets('Triggers onConfirm when confirm button is pressed', (
      tester,
    ) async {
      bool confirmCalled = false;
      await tester.pumpWidget(
        buildLocalizedMaterialApp(
          home: Scaffold(
            body: ReceiptVerificationDialog(
              merchantController: merchantController,
              dateController: dateController,
              onConfirm: () => confirmCalled = true,
              onCancel: () {},
              onDateTap: () {},
              onMerchantChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bestätigen'));
      expect(confirmCalled, isTrue);
    });

    testWidgets('Triggers onCancel when cancel button is pressed', (
      tester,
    ) async {
      bool cancelCalled = false;
      await tester.pumpWidget(
        buildLocalizedMaterialApp(
          home: Scaffold(
            body: ReceiptVerificationDialog(
              merchantController: merchantController,
              dateController: dateController,
              onConfirm: () {},
              onCancel: () => cancelCalled = true,
              onDateTap: () {},
              onMerchantChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abbrechen'));
      expect(cancelCalled, isTrue);
    });

    testWidgets('Triggers onDateTap when date field is tapped', (tester) async {
      bool dateTapCalled = false;
      await tester.pumpWidget(
        buildLocalizedMaterialApp(
          home: Scaffold(
            body: ReceiptVerificationDialog(
              merchantController: merchantController,
              dateController: dateController,
              onConfirm: () {},
              onCancel: () {},
              onDateTap: () => dateTapCalled = true,
              onMerchantChanged: (_) {},
            ),
          ),
        ),
      );

      // Tapping the date text field should trigger the callback
      await tester.tap(find.widgetWithText(TextField, '01.01.2025'));
      expect(dateTapCalled, isTrue);
    });

    testWidgets('Triggers onMerchantChanged when merchant name is edited', (
      tester,
    ) async {
      String changedValue = '';
      await tester.pumpWidget(
        buildLocalizedMaterialApp(
          home: Scaffold(
            body: ReceiptVerificationDialog(
              merchantController: merchantController,
              dateController: dateController,
              onConfirm: () {},
              onCancel: () {},
              onDateTap: () {},
              onMerchantChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Test Merchant'),
        'New Merchant',
      );
      expect(changedValue, 'New Merchant');
    });
  });
}
