import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_footer.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

void main() {
  testWidgets('ReceiptFooter renders total and save button', (tester) async {
    bool saved = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReceiptFooter(total: 12.34, onSave: () => saved = true),
        ),
      ),
    );

    expect(find.textContaining('12,34'), findsOneWidget);
    expect(find.textContaining('€'), findsOneWidget);
    expect(find.text('Speichern'), findsOneWidget);

    await tester.tap(find.text('Speichern'));
    expect(saved, isTrue);
  });
}
