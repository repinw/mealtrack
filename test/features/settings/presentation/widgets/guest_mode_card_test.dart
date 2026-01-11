import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/settings/presentation/widgets/guest_mode_card.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

void main() {
  testWidgets('GuestModeCard renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: GuestModeCard(onLinkAccount: () {})),
      ),
    );

    expect(find.byType(Card), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    // We can't easily check for localized text unless we know the exact string or force a locale.
    // But checking for icons and button is good enough.
    expect(find.byIcon(Icons.link), findsOneWidget);
  });

  testWidgets('GuestModeCard callbacks work', (tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GuestModeCard(
            onLinkAccount: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.link));
    expect(pressed, isTrue);
  });
}
