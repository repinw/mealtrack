import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class InventoryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const InventoryAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showOnlyAvailable = ref.watch(inventoryFilterProvider);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        Switch(
          value: showOnlyAvailable,
          onChanged: (value) {
            ref.read(inventoryFilterProvider.notifier).toggle();
          },
          activeThumbColor: Colors.green,
        ),
        if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: AppLocalizations.debugHiveReset,
            onPressed: () async {
              await ref.read(fridgeItemsProvider.notifier).deleteAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppLocalizations.debugDataDeleted),
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
