import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';

class InventorySpeedDial extends ConsumerWidget {
  const InventorySpeedDial({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(
      scannerViewModelProvider.select((s) => s.isLoading),
    );

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
          label: AppLocalizations.imageFromGallery,
          onTap: () => _analyzeAndNavigate(
            context,
            ref,
            () => ref
                .read(scannerViewModelProvider.notifier)
                .analyzeImageFromGallery(),
          ),
        ),
        SpeedDialChild(
          child: const Icon(Icons.camera_alt),
          label: AppLocalizations.imageFromCamera,
          onTap: () => _analyzeAndNavigate(
            context,
            ref,
            () => ref
                .read(scannerViewModelProvider.notifier)
                .analyzeImageFromCamera(),
          ),
        ),
        SpeedDialChild(
          child: const Icon(Icons.picture_as_pdf_rounded),
          label: AppLocalizations.imageFromPdf,
          onTap: () => _analyzeAndNavigate(
            context,
            ref,
            () => ref
                .read(scannerViewModelProvider.notifier)
                .analyzeImageFromPDF(),
          ),
        ),
      ],
    );
  }

  Future<void> _analyzeAndNavigate(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() analyzeAction,
  ) async {
    await analyzeAction();

    if (!context.mounted) return;

    final state = ref.read(scannerViewModelProvider);

    if (state.hasError) {
      _showErrorSnackBar(context, state.error!);
      return;
    }

    final result = state.value;

    if (result == null || result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppLocalizations.noAvailableProducts)),
      );
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ReceiptEditPage()));
  }

  void _showErrorSnackBar(BuildContext context, Object error) {
    String message = error.toString();
    if (error is ReceiptAnalysisException) {
      if (error.code == 'INVALID_JSON' ||
          error.originalException is FormatException) {
        message = AppLocalizations.receiptReadErrorFormat;
      } else {
        message = error.message;
      }
    } else if (message.contains('FormatException')) {
      message = AppLocalizations.receiptReadErrorFormat;
    } else {
      message = '${AppLocalizations.errorOccurred}$message';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
