import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/home/domain/home_tab.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scan_options_bottom_sheet.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/add_shopping_item_dialog.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class HomeFab extends ConsumerWidget {
  final HomeTab currentTab;

  const HomeFab({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FloatingActionButton(
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: () => _onPressed(context),
        child: _buildIcon(context, ref),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    switch (currentTab) {
      case HomeTab.inventory:
        ScanOptionsBottomSheet.show(context);
        break;
      case HomeTab.shoppingList:
        showDialog(
          context: context,
          builder: (context) => const AddShoppingItemDialog(),
        );
        break;
      default:
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addItemNotImplemented)));
    }
  }

  Widget _buildIcon(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerViewModelProvider);
    final isInventoryLoading =
        currentTab == HomeTab.inventory && scannerState.isLoading;

    if (isInventoryLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final IconData icon = currentTab == HomeTab.inventory
        ? Icons.center_focus_weak
        : Icons.add;

    return Icon(icon);
  }
}
