import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/l10n/l10n.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_tabs.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

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
        child: const MaterialApp(home: Scaffold(body: InventoryTabs())),
      );
    }

    testWidgets('renders all three filter tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text(L10n.filterAll), findsOneWidget);
      expect(find.text(L10n.filterAvailable), findsOneWidget);
      expect(find.text(L10n.filterEmpty), findsOneWidget);
    });

    testWidgets('tapping Available tab calls setFilter with available', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text(L10n.filterAvailable));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.available);
    });

    testWidgets('tapping Empty tab calls setFilter with empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text(L10n.filterEmpty));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.empty);
    });

    testWidgets('tapping All tab calls setFilter with all', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text(L10n.filterAvailable));
      await tester.pumpAndSettle();
      await tester.tap(find.text(L10n.filterAll));
      await tester.pumpAndSettle();

      expect(mockFilterNotifier.lastSetFilter, InventoryFilterType.all);
    });

    testWidgets('selected tab has bold text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final allesText = tester.widget<Text>(
        find.text(L10n.filterAll),
      );
      expect(allesText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('unselected tabs have normal weight text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final availableText = tester.widget<Text>(
        find.text(L10n.filterAvailable),
      );
      expect(availableText.style?.fontWeight, FontWeight.normal);

      final emptyText = tester.widget<Text>(
        find.text(L10n.filterEmpty),
      );
      expect(emptyText.style?.fontWeight, FontWeight.normal);
    });
  });
}
