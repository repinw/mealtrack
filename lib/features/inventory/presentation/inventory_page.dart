import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_sliver_app_bar.dart';

class InventoryPage extends StatelessWidget {
  final String title;
  final WidgetBuilder? sharingPageBuilder;
  final WidgetBuilder? settingsPageBuilder;

  const InventoryPage({
    super.key,
    required this.title,
    this.sharingPageBuilder,
    this.settingsPageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            InventorySliverAppBar(
              title: title,
              onOpenSharing: () {
                final pageBuilder = sharingPageBuilder;
                if (pageBuilder == null) return;
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: pageBuilder));
              },
              onOpenSettings: () {
                final pageBuilder = settingsPageBuilder;
                if (pageBuilder == null) return;
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: pageBuilder));
              },
            ),
          ];
        },
        body: const InventoryList(),
      ),
    );
  }
}
