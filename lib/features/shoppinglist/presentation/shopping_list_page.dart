import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_item_row.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListAsync = ref.watch(shoppingListProvider);

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
          if (items.isEmpty) {
            return Center(child: Text(l10n.shoppingListEmpty));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  ref.read(shoppingListProvider.notifier).deleteItem(item.id);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ShoppingListItemRow(item: item),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.errorDisplay(err))),
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
