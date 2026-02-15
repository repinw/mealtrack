import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_appbar/inventory_sliver_app_bar.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import '../../../../shared/test_helpers.dart';

class MockFridgeItemsNotifier extends FridgeItems {
  MockFridgeItemsNotifier([this.mockItems = const []]);

  final List<FridgeItem> mockItems;
  bool deleteAllCalled = false;

  @override
  Stream<List<FridgeItem>> build() => Stream.value(mockItems);

  @override
  Future<void> deleteAll() async {
    deleteAllCalled = true;
  }
}

Widget _buildTestWidget({
  List<FridgeItem>? items,
  VoidCallback? onOpenSharing,
  VoidCallback? onOpenSettings,
}) {
  return ProviderScope(
    overrides: [
      fridgeItemsProvider.overrideWith(
        () => MockFridgeItemsNotifier(items ?? []),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              InventorySliverAppBar(
                title: 'Test Title',
                onOpenSharing: onOpenSharing ?? () {},
                onOpenSettings: onOpenSettings ?? () {},
              ),
            ];
          },
          body: ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) =>
                SizedBox(height: 56, child: Text('Row $index')),
          ),
        ),
      ),
    ),
  );
}

Finder _expandedOpacityFinder() {
  return find.ancestor(
    of: find.byKey(const ValueKey('inventory-expanded-summary')),
    matching: find.byType(Opacity),
  );
}

Finder _collapsedOpacityFinder() {
  return find.ancestor(
    of: find.byKey(const ValueKey('inventory-collapsed-stats')),
    matching: find.byType(Opacity),
  );
}

double _opacityOrFallback(
  WidgetTester tester,
  Finder finder, {
  required double fallback,
}) {
  if (finder.evaluate().isEmpty) {
    return fallback;
  }

  return tester.widget<Opacity>(finder.first).opacity;
}

void main() {
  group('InventorySliverAppBar', () {
    testWidgets('renders title and action icons', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('VORRAT'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('calls sharing and settings callbacks on tap', (tester) async {
      var sharingTapped = false;
      var settingsTapped = false;

      await tester.pumpWidget(
        _buildTestWidget(
          onOpenSharing: () => sharingTapped = true,
          onOpenSettings: () => settingsTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      expect(sharingTapped, isTrue);
      expect(settingsTapped, isTrue);
    });

    testWidgets('debug delete button clears data and shows snackbar', (
      tester,
    ) async {
      final item = createTestFridgeItem(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
      );
      final notifier = MockFridgeItemsNotifier([item]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [fridgeItemsProvider.overrideWith(() => notifier)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            home: Scaffold(
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    const InventorySliverAppBar(
                      title: 'Test Title',
                      onOpenSharing: _noop,
                      onOpenSettings: _noop,
                    ),
                  ];
                },
                body: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(notifier.deleteAllCalled, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets(
      'fades expanded summary out and collapsed summary in on scroll',
      (tester) async {
        final items = [
          createTestFridgeItem(
            name: 'Milk',
            storeName: 'Store',
            quantity: 2,
            unitPrice: 1.5,
          ),
        ];

        await tester.pumpWidget(_buildTestWidget(items: items));
        await tester.pumpAndSettle();

        expect(find.text('VORRATSWERT'), findsWidgets);

        final expandedAtTop = _opacityOrFallback(
          tester,
          _expandedOpacityFinder(),
          fallback: 0.0,
        );
        final collapsedAtTop = _opacityOrFallback(
          tester,
          _collapsedOpacityFinder(),
          fallback: 0.0,
        );
        expect(expandedAtTop, greaterThan(0.9));
        expect(collapsedAtTop, lessThan(0.1));

        await tester.drag(find.byType(NestedScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();

        final expandedAfterScroll = _opacityOrFallback(
          tester,
          _expandedOpacityFinder(),
          fallback: 0.0,
        );
        final collapsedAfterScroll = _opacityOrFallback(
          tester,
          _collapsedOpacityFinder(),
          fallback: 1.0,
        );
        expect(expandedAfterScroll, lessThan(0.1));
        expect(collapsedAfterScroll, greaterThan(0.9));
        expect(find.text('VORRATSWERT'), findsWidgets);
        expect(find.text('EINKÄUFE'), findsOneWidget);
        expect(find.text('TEILE'), findsOneWidget);
      },
    );
  });
}

void _noop() {}
