import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_item_row.dart';

class DismissibleShoppingItem extends ConsumerWidget {
  final ShoppingListItem item;

  const DismissibleShoppingItem({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('shopping_item_${item.id}'),
      direction: DismissDirection.endToStart,
      background: const _DeleteBackground(),
      onDismissed: (_) {
        ref.read(shoppingListProvider.notifier).deleteItem(item.id);
      },
      child: ShoppingListItemRow(item: item),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: Icon(Icons.delete, color: colorScheme.onError),
    );
  }
}
