import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/filter.dart';
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
  group('FilterWidget', () {
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
          home: Scaffold(body: FilterWidget()),
        ),
      );
    }

    testWidgets('renders filter icon button', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(PopupMenuButton<InventoryFilterType>), findsOneWidget);
      expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
    });

    testWidgets('dropdown shows all filter options when opened', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byType(PopupMenuButton<InventoryFilterType>));
      await tester.pumpAndSettle();

      expect(find.text('Vorrat'), findsOneWidget);
      expect(find.text('Alle'), findsOneWidget);
      expect(find.text('Verbraucht'), findsOneWidget);
    });

    testWidgets('selecting available keeps filter on available', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(initialFilter: InventoryFilterType.all),
      );

      await tester.tap(find.byType(PopupMenuButton<InventoryFilterType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vorrat').last);
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.available);
    });

    testWidgets('selecting consumed calls setFilter with consumed', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byType(PopupMenuButton<InventoryFilterType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verbraucht').last);
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.consumed);
    });

    testWidgets('selecting all calls setFilter with all', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byType(PopupMenuButton<InventoryFilterType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alle').last);
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.all);
    });

    testWidgets('opening menu does not break with consumed as initial', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(initialFilter: InventoryFilterType.consumed),
      );

      await tester.tap(find.byType(PopupMenuButton<InventoryFilterType>));
      await tester.pumpAndSettle();

      expect(find.text('Verbraucht'), findsOneWidget);
    });
  });
}
