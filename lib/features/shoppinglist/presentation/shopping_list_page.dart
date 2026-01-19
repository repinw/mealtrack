import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_item_row.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListAsync = ref.watch(shoppingListProvider);

    final l10n = AppLocalizations.of(context)!;

    const labelColor = Colors.grey;
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    const textColor = AppTheme.white;
    final stats = ref.watch(shoppingListStatsProvider);

    const double bottomHeight = 80.0;

    const accentColor = AppTheme.secondaryColor;
    const highlightColor = AppTheme.accentColor;

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "UNGEFÄHRE KOSTEN",
                      style: TextStyle(
                        fontSize: 12,
                        color: labelColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(stats.totalValue),
                      style: const TextStyle(
                        fontSize: 32,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        l10n.items(stats.articleCount),
                        style: const TextStyle(
                          color: highlightColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
