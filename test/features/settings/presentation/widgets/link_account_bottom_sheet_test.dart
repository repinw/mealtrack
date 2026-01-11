import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/settings/presentation/widgets/link_account_bottom_sheet.dart';
import 'package:mealtrack/core/l10n/l10n.dart';

void main() {
  testWidgets('LinkAccountBottomSheet renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LinkAccountBottomSheet(
            onNewAccount: () {},
            onUseExistingAccount: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.person_add), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });

  testWidgets('LinkAccountBottomSheet triggers callbacks', (tester) async {
    bool newAccountPressed = false;
    bool existingAccountPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => LinkAccountBottomSheet(
                        onNewAccount: () => newAccountPressed = true,
                        onUseExistingAccount: () =>
                            existingAccountPressed = true,
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Open the sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify sheet is open
    expect(find.byType(LinkAccountBottomSheet), findsOneWidget);

    // Test New Account button
    await tester.tap(find.text(L10n.createNewAccount));
    await tester.pumpAndSettle(); // Allow pop animation

    expect(newAccountPressed, isTrue);
    expect(
      find.byType(LinkAccountBottomSheet),
      findsNothing,
    ); // Should be closed

    // Re-open for second button
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Test Existing Account button
    await tester.tap(find.text(L10n.useExistingAccount));
    await tester.pumpAndSettle();

    expect(existingAccountPressed, isTrue);
    expect(find.byType(LinkAccountBottomSheet), findsNothing);
  });
}
