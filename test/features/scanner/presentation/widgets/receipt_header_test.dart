import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_header.dart';

void main() {
  testWidgets('ReceiptHeader renders controllers and handles input', (
    tester,
  ) async {
    final merchantController = TextEditingController(text: 'Initial Store');
    final dateController = TextEditingController(text: '12.12.2023');
    String? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceiptHeader(
            merchantController: merchantController,
            dateController: dateController,
            onMerchantChanged: (val) => changedValue = val,
          ),
        ),
      ),
    );

    expect(find.text('Initial Store'), findsOneWidget);
    expect(find.text('12.12.2023'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Initial Store'),
      'New Store',
    );
    expect(changedValue, 'New Store');
  });
}
