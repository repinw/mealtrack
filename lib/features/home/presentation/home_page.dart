import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/home/presentation/home_viewmodel.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_viewmodel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);

    ref.listen<AsyncValue<List<FridgeItem>>>(homeViewModelProvider, (
      previous,
      next,
    ) {
      // Only process results when transitioning FROM loading state
      // AND when previous state had data (meaning user initiated an action)
      if (previous?.isLoading != true) return;
      if (!previous!.hasValue) return; // Skip initial build

      next.when(
        data: (result) {
          if (!context.mounted) return;
          if (result.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppLocalizations.noAvailableProducts),
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProviderScope(
                overrides: [
                  initialScannedItemsProvider.overrideWithValue(result),
                  receiptEditViewModelProvider.overrideWith(
                    ReceiptEditViewModel.new,
                  ),
                ],
                child: ReceiptEditPage(scannedItems: result),
              ),
            ),
          );
        },
        loading: () {},
        error: (error, stack) {
          _showErrorSnackBar(context, error);
        },
      );
    });

    return Scaffold(
      floatingActionButton: _buildSpeedDial(ref, homeState.isLoading),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: homeState.isLoading
            ? const CircularProgressIndicator()
            : const InventoryPage(title: 'Digitaler Kühlschrank'),
      ),
    );
  }

  Widget _buildSpeedDial(WidgetRef ref, bool isBusy) {
    if (isBusy) return const SizedBox.shrink();

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.photo_library),
          label: 'Bild aus Galerie',
          onTap: () => ref
              .read(homeViewModelProvider.notifier)
              .analyzeImageFromGallery(),
        ),
      ],
    );
  }

  void _showErrorSnackBar(BuildContext context, Object error) {
    String message = error.toString();
    if (error is ReceiptAnalysisException) {
      // Ideally use error.code to map to localized strings, but for now we use the refined logic
      if (error.code == 'INVALID_JSON' ||
          error.originalException is FormatException) {
        message = 'Der Kassenbon konnte nicht gelesen werden (Format-Fehler).';
      } else {
        message = error.message;
      }
    } else if (message.contains('FormatException')) {
      // Fallback
      message = 'Der Kassenbon konnte nicht gelesen werden (Format-Fehler).';
    } else {
      message = 'Ein Fehler ist aufgetreten: $message';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
