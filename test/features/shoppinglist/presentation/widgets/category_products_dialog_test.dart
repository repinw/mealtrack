import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/data/category_stats_repository.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/product_suggestion.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/category_products_dialog.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class _FakeCategoryStatsRepository extends CategoryStatsRepository {
  _FakeCategoryStatsRepository() : super(FakeFirebaseFirestore(), 'uid');

  final _controller = StreamController<List<ProductSuggestion>>.broadcast();

  void emit(List<ProductSuggestion> products) => _controller.add(products);

  @override
  Stream<List<ProductSuggestion>> watchProductsForCategory(String category) =>
      _controller.stream;
}

class _FakeShoppingListRepository implements ShoppingListRepository {
  final List<Map<String, Object?>> addCalls = [];
  final List<ShoppingListItem> items;

  _FakeShoppingListRepository(this.items);

  @override
  Future<void> addItem(ShoppingListItem item) async {}

  @override
  Future<void> addOrMergeItem({
    required String name,
    required String? brand,
    String? category,
    required int quantity,
    required double? unitPrice,
  }) async {
    addCalls.add({
      'name': name,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
    });
  }

  @override
  Future<void> clearList() async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<void> updateItem(ShoppingListItem item) async {}

  @override
  Stream<List<ShoppingListItem>> watchItems() => Stream.value(items);
}

class _DialogLauncher extends ConsumerWidget {
  const _DialogLauncher({required this.onResult});
  final ValueChanged<int> onResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final result = await showCategoryProductsDialog(
          context: context,
          ref: ref,
          category: 'Dairy',
          categoryAveragePrice: 2.0,
        );
        onResult(result);
      },
      child: const Text('Open'),
    );
  }
}

void main() {
  Widget _app({
    required CategoryStatsRepository categoryRepo,
    required ShoppingListRepository shoppingRepo,
    required ValueChanged<int> onResult,
  }) {
    return ProviderScope(
      overrides: [
        categoryStatsRepositoryProvider.overrideWith((ref) => categoryRepo),
        shoppingListRepositoryProvider.overrideWith((ref) => shoppingRepo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(body: _DialogLauncher(onResult: onResult)),
      ),
    );
  }

  testWidgets('shows loading, adds selected products, and returns count', (tester) async {
    final categoryRepo = _FakeCategoryStatsRepository();
    final shoppingRepo = _FakeShoppingListRepository(const []);
    var dialogResult = -1;

    await tester.pumpWidget(
      _app(
        categoryRepo: categoryRepo,
        shoppingRepo: shoppingRepo,
        onResult: (v) => dialogResult = v,
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    categoryRepo.emit(
      const [
        ProductSuggestion(name: 'Milk', averagePrice: 1.5, count: 3),
        ProductSuggestion(name: 'Yogurt', averagePrice: 0, count: 1),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Dairy'), findsOneWidget);
    expect(find.text('~1.50 €'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Milk'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Milk'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Milk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(shoppingRepo.addCalls.length, 1);
    expect(shoppingRepo.addCalls.first['name'], 'Milk');
    expect(shoppingRepo.addCalls.first['category'], 'Dairy');
    expect(dialogResult, 1);
  });

  testWidgets('shows empty message and cancel returns 0', (tester) async {
    final categoryRepo = _FakeCategoryStatsRepository();
    final shoppingRepo = _FakeShoppingListRepository(
      const [ShoppingListItem(id: '1', name: 'Milk')],
    );
    var dialogResult = -1;

    await tester.pumpWidget(
      _app(
        categoryRepo: categoryRepo,
        shoppingRepo: shoppingRepo,
        onResult: (v) => dialogResult = v,
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    categoryRepo.emit(const [ProductSuggestion(name: 'Milk', averagePrice: 1, count: 2)]);
    await tester.pumpAndSettle();

    expect(find.text('Keine Produkte gefunden'), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(dialogResult, 0);
    expect(shoppingRepo.addCalls, isEmpty);
  });
}
