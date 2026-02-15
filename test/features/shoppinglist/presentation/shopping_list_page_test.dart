import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mealtrack/core/presentation/widgets/feature_sliver_app_bar.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/presentation/shopping_list_page.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_appbar/shopping_list_cost_summary.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_appbar/shopping_list_sliver_app_bar.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/data/category_stats_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/category_suggestion.dart';
import 'package:mealtrack/features/shoppinglist/provider/suggestions_provider.dart';
import 'package:mealtrack/features/shoppinglist/domain/product_suggestion.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

// Fake Repository for UI Test
class FakeShoppingListRepository implements ShoppingListRepository {
  List<ShoppingListItem> items;
  final _controller = StreamController<List<ShoppingListItem>>.broadcast();

  FakeShoppingListRepository(this.items);

  @override
  Stream<List<ShoppingListItem>> watchItems() async* {
    yield items;
    yield* _controller.stream;
  }

  @override
  Future<void> addItem(ShoppingListItem item) async {
    items = [...items, item];
    _controller.add(items);
  }

  @override
  Future<void> addOrMergeItem({
    required String name,
    required String? brand,
    String? category,
    required int quantity,
    required double? unitPrice,
  }) async {
    // Basic implementation for test if needed, or just stub
    final newItem = ShoppingListItem.create(
      name: name,
      brand: brand,
      category: category,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    items = [...items, newItem];
    _controller.add(items);
  }

  final List<String> deletedIds = [];

  @override
  Future<void> deleteItem(String id) async {
    deletedIds.add(id);
    items = items.where((i) => i.id != id).toList();
    _controller.add(items);
  }

  @override
  Future<void> updateItem(ShoppingListItem item) async {
    items = items.map((i) => i.id == item.id ? item : i).toList();
    _controller.add(items);
  }

  bool clearListCalled = false;
  @override
  Future<void> clearList() async {
    clearListCalled = true;
    items = [];
    _controller.add(items);
  }
}

class ErrorShoppingListRepository implements ShoppingListRepository {
  @override
  Future<void> addItem(ShoppingListItem item) async {}

  @override
  Future<void> addOrMergeItem({
    required String name,
    required String? brand,
    String? category,
    required int quantity,
    required double? unitPrice,
  }) async {}

  @override
  Future<void> clearList() async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<void> updateItem(ShoppingListItem item) async {}

  @override
  Stream<List<ShoppingListItem>> watchItems() {
    return Stream<List<ShoppingListItem>>.error(Exception('boom'));
  }
}

class FakeCategoryStatsRepository extends CategoryStatsRepository {
  FakeCategoryStatsRepository(this.products)
    : super(FakeFirebaseFirestore(), 'uid');

  final List<ProductSuggestion> products;

  @override
  Stream<List<ProductSuggestion>> watchProductsForCategory(String category) {
    return Stream.value(products);
  }
}

void main() {
  Future<void> pumpShoppingListPage(
    WidgetTester tester,
    ShoppingListRepository repository,
    List<CategorySuggestion> suggestions,
    CategoryStatsRepository categoryStatsRepository, {
    List<ProductQuickSuggestion> quickSuggestions = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
          suggestionsProvider.overrideWith((ref) => suggestions),
          quickProductSuggestionsProvider.overrideWith(
            (ref) => quickSuggestions,
          ),
          categoryStatsRepositoryProvider.overrideWith(
            (ref) => categoryStatsRepository,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShoppingListPage(),
        ),
      ),
    );
    // Allow FutureBuilder/StreamBuilder to resolve
    await tester.pump();
  }

  testWidgets('ShoppingListPage renders list of items', (tester) async {
    const item1 = ShoppingListItem(id: '1', name: 'Apples');
    const item2 = ShoppingListItem(id: '2', name: 'Bananas');

    final repository = FakeShoppingListRepository([item1, item2]);

    await pumpShoppingListPage(
      tester,
      repository,
      const [],
      FakeCategoryStatsRepository(const []),
    );

    // Verify Title
    expect(find.text('EINKAUFSLISTE'), findsOneWidget);

    // Verify Items
    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Bananas'), findsOneWidget);

    // Verify Stats Header
    expect(find.byType(ShoppingListCostSummary), findsOneWidget);
    expect(find.text('UNGEFÄHRE KOSTEN'), findsWidgets);
    expect(find.byType(FeatureSliverAppBar), findsOneWidget);

    final summaryAlignmentFinder = find.ancestor(
      of: find.byType(ShoppingListCostSummary),
      matching: find.byWidgetPredicate((widget) {
        return widget is Align && widget.alignment == Alignment.bottomLeft;
      }),
    );
    expect(summaryAlignmentFinder, findsOneWidget);
  });

  testWidgets(
    'title and expanded summary collapse while collapsed stats fade in',
    (tester) async {
      final repository = FakeShoppingListRepository(
        List.generate(
          24,
          (index) => ShoppingListItem(id: '$index', name: 'Item $index'),
        ),
      );

      await pumpShoppingListPage(
        tester,
        repository,
        const [],
        FakeCategoryStatsRepository(const []),
      );

      final titleOpacityFinder = find.byKey(
        const ValueKey('shopping-expanded-title-opacity'),
      );
      final expandedSummaryOpacityFinder = find.byKey(
        const ValueKey('shopping-expanded-summary-opacity'),
      );
      final collapsedStatsOpacityFinder = find.byKey(
        const ValueKey('shopping-collapsed-stats-opacity'),
      );

      final titleOpacityAtTop = tester
          .widget<Opacity>(titleOpacityFinder)
          .opacity;
      final expandedSummaryOpacityAtTop = tester
          .widget<Opacity>(expandedSummaryOpacityFinder)
          .opacity;
      final collapsedStatsOpacityAtTop = tester
          .widget<Opacity>(collapsedStatsOpacityFinder)
          .opacity;

      expect(titleOpacityAtTop, greaterThan(0.9));
      expect(expandedSummaryOpacityAtTop, greaterThan(0.9));
      expect(collapsedStatsOpacityAtTop, lessThan(0.1));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
      await tester.pumpAndSettle();

      final titleOpacityAfterScroll = tester
          .widget<Opacity>(titleOpacityFinder)
          .opacity;
      final expandedSummaryOpacityAfterScroll = tester
          .widget<Opacity>(expandedSummaryOpacityFinder)
          .opacity;
      final collapsedStatsOpacityAfterScroll = tester
          .widget<Opacity>(collapsedStatsOpacityFinder)
          .opacity;

      expect(titleOpacityAfterScroll, lessThan(0.1));
      expect(expandedSummaryOpacityAfterScroll, lessThan(0.1));
      expect(collapsedStatsOpacityAfterScroll, greaterThan(0.9));
    },
  );

  testWidgets('ShoppingListPage renders empty state', (tester) async {
    final repository = FakeShoppingListRepository([]);

    await pumpShoppingListPage(
      tester,
      repository,
      const [],
      FakeCategoryStatsRepository(const []),
    );

    expect(find.text('Keine Einträge'), findsOneWidget);
  });

  testWidgets('swiping item dismisses it', (tester) async {
    const item = ShoppingListItem(id: '1', name: 'Apples');
    final repository = FakeShoppingListRepository([item]);

    await pumpShoppingListPage(
      tester,
      repository,
      const [],
      FakeCategoryStatsRepository(const []),
    );

    // Swipe item
    await tester.drag(find.text('Apples'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Verify delete was called
    expect(repository.deletedIds, contains('1'));
  });

  testWidgets('tapping clear list button shows confirmation and clears list', (
    tester,
  ) async {
    final repository = FakeShoppingListRepository([]);

    await pumpShoppingListPage(
      tester,
      repository,
      const [],
      FakeCategoryStatsRepository(const []),
    );

    // Tap delete all button
    await tester.tap(find.byIcon(Icons.delete_sweep));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Liste leeren?'), findsOneWidget);
    expect(
      find.text('Möchtest du wirklich alle Einträge löschen?'),
      findsOneWidget,
    );

    // Tap Confirm
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    // Verify clearList was called
    expect(repository.clearListCalled, true);
  });

  testWidgets('cancel clear dialog does not clear list', (tester) async {
    final repository = FakeShoppingListRepository([]);
    await pumpShoppingListPage(
      tester,
      repository,
      const [],
      FakeCategoryStatsRepository(const []),
    );

    await tester.tap(find.byIcon(Icons.delete_sweep));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(repository.clearListCalled, false);
  });

  testWidgets('tapping suggestion opens category dialog', (tester) async {
    final repository = FakeShoppingListRepository([]);
    await pumpShoppingListPage(
      tester,
      repository,
      const [CategorySuggestion(name: 'Dairy', averagePrice: 1.5)],
      FakeCategoryStatsRepository(const [
        ProductSuggestion(name: 'Milk', averagePrice: 1.5, count: 2),
      ]),
    );

    await tester.tap(find.text('Dairy'));
    await tester.pumpAndSettle();

    expect(find.text('Dairy'), findsWidgets);
    expect(find.text('Milk'), findsOneWidget);
  });

  testWidgets('tapping quick suggestion adds item directly', (tester) async {
    final repository = FakeShoppingListRepository([]);
    await pumpShoppingListPage(
      tester,
      repository,
      const [],
      FakeCategoryStatsRepository(const []),
      quickSuggestions: const [
        (name: 'Milk', category: 'Dairy', averagePrice: 1.5, count: 4),
      ],
    );

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(repository.items.length, 1);
    expect(repository.items.first.name, 'Milk');
    expect(repository.items.first.category, 'Dairy');
    expect(repository.items.first.unitPrice, 1.5);
  });

  testWidgets('renders error state when stream fails', (tester) async {
    await pumpShoppingListPage(
      tester,
      ErrorShoppingListRepository(),
      const [],
      FakeCategoryStatsRepository(const []),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('boom'), findsOneWidget);
  });
}
