import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/features/shoppinglist/provider/suggestions_provider.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/category_products_dialog.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/dismissible_shopping_item.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/suggestion_area.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});
  static const double _scrollBottomSpacing = 144;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListAsync = ref.watch(shoppingListProvider);
    final suggestions = ref.watch(suggestionsProvider);
    final quickProductSuggestions = ref.watch(quickProductSuggestionsProvider);

    final l10n = AppLocalizations.of(context)!;

    final stats = ref.watch(shoppingListStatsProvider);

    const double bottomHeight = 80.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppinglist),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmClearList(context, ref),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(bottomHeight),
          child: SummaryHeader(
            label: l10n.approximateCostLabel,
            totalValue: stats.totalValue,
            articleCount: stats.articleCount,
          ),
        ),
      ),
      body: shoppingListAsync.when(
        data: (items) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SuggestionArea(
                  title: l10n.add,
                  icon: Icons.add_circle_outline,
                  suggestions: quickProductSuggestions
                      .map((product) => product.name)
                      .toList(),
                  onSuggestionTap: (name) {
                    final suggestion = quickProductSuggestions
                        .where((item) => item.name == name)
                        .firstOrNull;
                    if (suggestion == null) return;

                    ref
                        .read(shoppingListProvider.notifier)
                        .addItem(
                          name,
                          category: suggestion.category,
                          unitPrice: suggestion.averagePrice > 0
                              ? suggestion.averagePrice
                              : null,
                        );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: SuggestionArea(
                  suggestions: suggestions.map((s) => s.name).toList(),
                  onSuggestionTap: (name) {
                    final suggestion = suggestions
                        .where((s) => s.name == name)
                        .firstOrNull;
                    showCategoryProductsDialog(
                      context: context,
                      ref: ref,
                      category: name,
                      categoryAveragePrice: suggestion?.averagePrice ?? 0,
                    );
                  },
                ),
              ),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.shoppingListEmpty)),
                )
              else
                SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      DismissibleShoppingItem(item: items[index]),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: _scrollBottomSpacing),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text(l10n.errorDisplay(err.toString()))),
      ),
    );
  }

  Future<void> _confirmClearList(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.shoppingListClearTitle),
        content: Text(l10n.shoppingListClearConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(shoppingListProvider.notifier).clearList();
    }
  }
}
