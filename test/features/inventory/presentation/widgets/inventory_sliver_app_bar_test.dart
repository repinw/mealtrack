import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_sliver_app_bar.dart';
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
  return find.byWidgetPredicate(
    (widget) => widget is Opacity && widget.child is Column,
    description: 'expanded summary opacity',
  );
}

Finder _collapsedOpacityFinder() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Opacity &&
        widget.child is SizedBox &&
        (widget.child as SizedBox).height == kToolbarHeight,
    description: 'collapsed summary opacity',
  );
}

void main() {
  group('InventorySliverAppBar', () {
    testWidgets('renders title and action icons', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('TEST TITLE'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
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

      await tester.tap(find.byIcon(Icons.delete_forever));
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

        expect(find.byType(SummaryHeader), findsOneWidget);

        final expandedAtTop = tester.widget<Opacity>(_expandedOpacityFinder());
        final collapsedAtTop = tester.widget<Opacity>(
          _collapsedOpacityFinder(),
        );
        expect(expandedAtTop.opacity, greaterThan(0.9));
        expect(collapsedAtTop.opacity, lessThan(0.1));

        await tester.drag(find.byType(NestedScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();

        final expandedAfterScroll = tester.widget<Opacity>(
          _expandedOpacityFinder(),
        );
        final collapsedAfterScroll = tester.widget<Opacity>(
          _collapsedOpacityFinder(),
        );
        expect(expandedAfterScroll.opacity, lessThan(0.1));
        expect(collapsedAfterScroll.opacity, greaterThan(0.9));
        expect(find.byType(SummaryHeader), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Text && (widget.data?.contains('•') ?? false),
          ),
          findsOneWidget,
        );
      },
    );
  });
}

void _noop() {}
