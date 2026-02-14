import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_tabs.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class MockInventoryFilterNotifier extends InventoryFilter {
  MockInventoryFilterNotifier(this._filter);

  InventoryFilterType _filter;
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
      InventoryFilterType initialFilter = InventoryFilterType.available,
    }) {
      mockFilterNotifier = MockInventoryFilterNotifier(initialFilter);
      return ProviderScope(
        overrides: [
          inventoryFilterProvider.overrideWith(() => mockFilterNotifier),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(body: InventoryTabs()),
        ),
      );
    }

    testWidgets('renders all tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Alle'), findsOneWidget);
      expect(find.text('Vorrat'), findsOneWidget);
      expect(find.text('Verbraucht'), findsOneWidget);
    });

    testWidgets('selecting available keeps filter on available', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(initialFilter: InventoryFilterType.all),
      );

      await tester.tap(find.text('Vorrat'));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.available);
    });

    testWidgets('selecting consumed calls setFilter with consumed', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Verbraucht'));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.consumed);
    });

    testWidgets('selecting all calls setFilter with all', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Alle'));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.all);
    });

    testWidgets('opening menu does not break with consumed as initial', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(initialFilter: InventoryFilterType.consumed),
      );

      expect(find.text('Verbraucht'), findsOneWidget);
    });
  });
}
