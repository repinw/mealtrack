import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/data/category_stats_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/category_suggestion.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/features/shoppinglist/provider/suggestions_provider.dart';

class _FakeShoppingListNotifier extends ShoppingList {
  _FakeShoppingListNotifier(this.items);
  final List<ShoppingListItem> items;

  @override
  Stream<List<ShoppingListItem>> build() => Stream.value(items);
}

class _FakeCategoryStatsRepository extends CategoryStatsRepository {
  _FakeCategoryStatsRepository(this.categories, this.quickProducts)
    : super(FakeFirebaseFirestore(), 'uid');

  final List<CategorySuggestion> categories;
  final List<ProductQuickSuggestion> quickProducts;

  @override
  Stream<List<CategorySuggestion>> watchTopCategories({int limit = 10}) {
    return Stream.value(categories.take(limit).toList());
  }

  @override
  Stream<List<ProductQuickSuggestion>> watchTopProducts({int limit = 10}) {
    return Stream.value(quickProducts.take(limit).toList());
  }
}

void main() {
  test(
    'suggestions filters existing shopping categories and limits to 10',
    () async {
      final categories = List.generate(
        12,
        (i) => CategorySuggestion(name: 'Cat$i', averagePrice: i.toDouble()),
      );
      final fakeRepo = _FakeCategoryStatsRepository(categories, const []);
      final shoppingItems = const [
        ShoppingListItem(id: '1', name: 'Milk', category: 'cat1'),
        ShoppingListItem(id: '2', name: 'Bread', category: 'cat3'),
        ShoppingListItem(id: '3', name: 'NoCategory'),
      ];

      final container = ProviderContainer(
        overrides: [
          categoryStatsRepositoryProvider.overrideWith((ref) => fakeRepo),
          shoppingListProvider.overrideWith(
            () => _FakeShoppingListNotifier(shoppingItems),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.listen(categoryStatsStreamProvider, (_, _) {});
      await container.read(categoryStatsStreamProvider.future);
      container.listen(shoppingListProvider, (_, _) {});
      await container.read(shoppingListProvider.future);

      final result = container.read(suggestionsProvider);
      expect(result.length, 10);
      expect(result.any((s) => s.name == 'Cat1'), isFalse);
      expect(result.any((s) => s.name == 'Cat3'), isFalse);
    },
  );

  test('categoryStatsStream delegates to repository with limit 20', () async {
    final categories = List.generate(
      25,
      (i) => CategorySuggestion(name: 'C$i', averagePrice: 1.0),
    );
    final fakeRepo = _FakeCategoryStatsRepository(categories, const []);
    final container = ProviderContainer(
      overrides: [
        categoryStatsRepositoryProvider.overrideWith((ref) => fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    container.listen(categoryStatsStreamProvider, (_, _) {});
    final values = await container.read(categoryStatsStreamProvider.future);
    expect(values.length, 20);
  });

  test(
    'quickProductSuggestions filters existing names and limits to 10',
    () async {
      final quickProducts = List.generate(
        12,
        (i) => (
          name: 'P$i',
          category: 'C$i',
          averagePrice: i.toDouble(),
          count: i + 1,
        ),
      );
      final fakeRepo = _FakeCategoryStatsRepository(const [], quickProducts);
      final shoppingItems = const [
        ShoppingListItem(id: '1', name: 'P1'),
        ShoppingListItem(id: '2', name: 'P3'),
      ];

      final container = ProviderContainer(
        overrides: [
          categoryStatsRepositoryProvider.overrideWith((ref) => fakeRepo),
          shoppingListProvider.overrideWith(
            () => _FakeShoppingListNotifier(shoppingItems),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.listen(quickProductSuggestionsStreamProvider, (_, _) {});
      await container.read(quickProductSuggestionsStreamProvider.future);
      container.listen(shoppingListProvider, (_, _) {});
      await container.read(shoppingListProvider.future);

      final result = container.read(quickProductSuggestionsProvider);
      expect(result.length, 10);
      expect(result.any((s) => s.name == 'P1'), isFalse);
      expect(result.any((s) => s.name == 'P3'), isFalse);
    },
  );

  test(
    'quickProductSuggestionsStream delegates to repository with limit 20',
    () async {
      final quickProducts = List.generate(
        25,
        (i) => (name: 'P$i', category: 'Cat', averagePrice: 1.0, count: 2),
      );
      final fakeRepo = _FakeCategoryStatsRepository(const [], quickProducts);
      final container = ProviderContainer(
        overrides: [
          categoryStatsRepositoryProvider.overrideWith((ref) => fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      container.listen(quickProductSuggestionsStreamProvider, (_, _) {});
      final values = await container.read(
        quickProductSuggestionsStreamProvider.future,
      );
      expect(values.length, 20);
    },
  );
}
