import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/shoppinglist/data/category_stats_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/product_suggestion.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

/// Shows a dialog with a checklist of products for a given [category].
/// Returns the number of items added to the shopping list.
Future<int> showCategoryProductsDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String category,
  required double categoryAveragePrice,
}) async {
  final result = await showDialog<int>(
    context: context,
    builder: (context) => _CategoryProductsDialog(
      category: category,
      categoryAveragePrice: categoryAveragePrice,
    ),
  );
  return result ?? 0;
}

class _CategoryProductsDialog extends ConsumerStatefulWidget {
  final String category;
  final double categoryAveragePrice;

  const _CategoryProductsDialog({
    required this.category,
    required this.categoryAveragePrice,
  });

  @override
  ConsumerState<_CategoryProductsDialog> createState() =>
      _CategoryProductsDialogState();
}

class _CategoryProductsDialogState
    extends ConsumerState<_CategoryProductsDialog> {
  final Set<String> _selected = {};
  List<ProductSuggestion> _products = [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.watch(categoryStatsRepositoryProvider);
    final shoppingListAsync = ref.watch(shoppingListProvider);
    final shoppingNames = (shoppingListAsync.asData?.value ?? [])
        .map((item) => item.name.toLowerCase())
        .toSet();

    return AlertDialog(
      title: Text(widget.category),
      content: StreamBuilder<List<ProductSuggestion>>(
        stream: repository.watchProductsForCategory(widget.category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          _products = (snapshot.data ?? [])
              .where((p) => !shoppingNames.contains(p.name.toLowerCase()))
              .toList();

          if (_products.isEmpty) {
            return SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  'Keine Produkte gefunden',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          }

          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final isSelected = _selected.contains(product.name);
                final priceText = product.averagePrice > 0
                    ? '~${product.averagePrice.toStringAsFixed(2)} €'
                    : null;

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selected.add(product.name);
                      } else {
                        _selected.remove(product.name);
                      }
                    });
                  },
                  title: Text(product.name),
                  subtitle: priceText != null ? Text(priceText) : null,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(0),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () async {
                  final notifier = ref.read(shoppingListProvider.notifier);

                  final selectedProducts = _selected.toList();
                  for (final name in selectedProducts) {
                    final product = _products
                        .where((p) => p.name == name)
                        .firstOrNull;
                    await notifier.addItem(
                      name,
                      unitPrice: product?.averagePrice,
                      category: widget.category,
                    );
                  }

                  if (!context.mounted) return;
                  Navigator.of(context).pop(_selected.length);
                },
          child: Text(l10n.add),
        ),
      ],
    );
  }
}
