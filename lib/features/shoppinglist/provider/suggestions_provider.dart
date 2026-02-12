import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/features/shoppinglist/data/category_stats_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/category_suggestion.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';

part 'suggestions_provider.g.dart';

@riverpod
List<CategorySuggestion> suggestions(Ref ref) {
  final categoriesAsync = ref.watch(categoryStatsStreamProvider);
  final shoppingListAsync = ref.watch(shoppingListProvider);

  final categories = categoriesAsync.asData?.value ?? <CategorySuggestion>[];
  final shoppingItems = shoppingListAsync.asData?.value ?? [];

  // Filter out categories that already have products on the shopping list
  final shoppingCategories = shoppingItems
      .where((item) => item.category != null)
      .map((item) => item.category!.toLowerCase())
      .toSet();

  return categories
      .where((s) => !shoppingCategories.contains(s.name.toLowerCase()))
      .take(10)
      .toList();
}

/// Raw stream from Firestore, kept separate so [suggestions] can combine it.
@riverpod
Stream<List<CategorySuggestion>> categoryStatsStream(Ref ref) {
  final repository = ref.watch(categoryStatsRepositoryProvider);
  return repository.watchTopCategories(limit: 20);
}

final quickProductSuggestionsStreamProvider =
    StreamProvider<List<ProductQuickSuggestion>>((ref) {
      final repository = ref.watch(categoryStatsRepositoryProvider);
      return repository.watchTopProducts(limit: 20);
    });

final quickProductSuggestionsProvider = Provider<List<ProductQuickSuggestion>>((
  ref,
) {
  final quickProductsAsync = ref.watch(quickProductSuggestionsStreamProvider);
  final shoppingListAsync = ref.watch(shoppingListProvider);

  final quickProducts =
      quickProductsAsync.asData?.value ?? const <ProductQuickSuggestion>[];
  final shoppingItems = shoppingListAsync.asData?.value ?? [];

  final shoppingNames = shoppingItems.map((item) => item.name.toLowerCase()).toSet();

  return quickProducts
      .where((product) => !shoppingNames.contains(product.name.toLowerCase()))
      .take(10)
      .toList();
});
