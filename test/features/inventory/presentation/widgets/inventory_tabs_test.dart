import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_tabs.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class MockInventoryFilterNotifier extends InventoryFilter {
  InventoryFilterType _filter = InventoryFilterType.all;
  InventoryFilterType? lastSetFilter;

  @override
  InventoryFilterType build() => _filter;

  @override
  void setFilter(InventoryFilterType type) {
    lastSetFilter = type;
    _filter = type;
    state = type;
  }
}

void main() {
  group('InventoryTabs', () {
    late MockInventoryFilterNotifier mockFilterNotifier;

    Widget buildTestWidget({
      InventoryFilterType initialFilter = InventoryFilterType.all,
    }) {
      mockFilterNotifier = MockInventoryFilterNotifier();
      return ProviderScope(
        overrides: [
          inventoryFilterProvider.overrideWith(() => mockFilterNotifier),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const Scaffold(body: InventoryTabs()),
        ),
      );
    }

    testWidgets('renders all three filter tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Alle'), findsOneWidget);
      expect(find.text('Vorrat'), findsOneWidget);
      expect(find.text('Verbraucht'), findsOneWidget);
    });

    testWidgets('tapping Available tab calls setFilter with available', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Vorrat'));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.available);
    });

    testWidgets('tapping Empty tab calls setFilter with empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Verbraucht'));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.empty);
    });

    testWidgets('tapping All tab calls setFilter with all', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Vorrat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alle'));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.all);
    });

    testWidgets('selected tab has bold text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final allesText = tester.widget<Text>(find.text('Alle'));
      expect(allesText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('unselected tabs have normal weight text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final availableText = tester.widget<Text>(find.text('Vorrat'));
      expect(availableText.style?.fontWeight, FontWeight.normal);

      final emptyText = tester.widget<Text>(find.text('Verbraucht'));
      expect(emptyText.style?.fontWeight, FontWeight.normal);
    });
  });
}
