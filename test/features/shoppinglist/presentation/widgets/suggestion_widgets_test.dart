import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/suggestion_area.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/suggestion_chip.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: Scaffold(body: child),
    );
  }

  testWidgets('SuggestionChip renders label and triggers tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapWidget(SuggestionChip(label: 'Dairy', onTap: () => tapped = true)),
    );

    expect(find.text('Dairy'), findsOneWidget);
    await tester.tap(find.byType(SuggestionChip));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets(
    'SuggestionArea renders, expands/collapses, and triggers callback',
    (tester) async {
      String? selected;
      await tester.pumpWidget(
        wrapWidget(
          SuggestionArea(
            suggestions: const ['A', 'B', 'C'],
            onSuggestionTap: (name) => selected = name,
          ),
        ),
      );

      expect(find.text('Vorschläge'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pump();
      expect(selected, 'A');

      await tester.tap(find.text('Vorschläge'));
      await tester.pumpAndSettle();
      expect(find.text('Vorschläge'), findsOneWidget);

      await tester.tap(find.text('Vorschläge'));
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
    },
  );

  testWidgets('SuggestionArea hides itself for empty list', (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        SuggestionArea(suggestions: const [], onSuggestionTap: (_) {}),
      ),
    );

    expect(find.byType(SuggestionChip), findsNothing);
    expect(find.text('Vorschläge'), findsNothing);
  });

  testWidgets('SuggestionArea uses custom title when provided', (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        SuggestionArea(
          title: 'Direkt',
          icon: Icons.add,
          suggestions: const ['Milk'],
          onSuggestionTap: (_) {},
        ),
      ),
    );

    expect(find.text('Direkt'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);
    expect(find.text('Vorschläge'), findsNothing);
  });
}
