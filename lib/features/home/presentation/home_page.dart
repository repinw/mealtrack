import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mealtrack/features/home/presentation/home_controller.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);

    ref.listen<AsyncValue<String?>>(homeControllerProvider, (previous, next) {
      // Only perform side-effects if transitioning from loading state
      if (previous?.isLoading != true) return;

      next.when(
        data: (result) {
          if (result == null) return; // User cancelled

          if (result.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Keine Produkte erkannt')),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReceiptEditPage(
                  scannedItems: parseScannedItemsFromJson(result)),
            ),
          );
        },
        loading: () {
          // While loading, the UI is already showing a progress indicator.
        },
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
          onTap: () =>
              ref.read(homeControllerProvider.notifier).analyzeImageFromGallery(),
        ),
      ],
    );
  }

  void _showErrorSnackBar(BuildContext context, Object error) {
    String message = error.toString();
    if (message.contains('FormatException')) {
      message = 'Der Kassenbon konnte nicht gelesen werden (Format-Fehler).';
    } else {
      message = 'Ein Fehler ist aufgetreten.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
