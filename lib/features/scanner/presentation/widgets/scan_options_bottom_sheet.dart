import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';

class ScanOptionsBottomSheet extends ConsumerWidget {
  const ScanOptionsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => const ScanOptionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.selectOption,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blueGrey),
            title: Text(l10n.imageFromCamera),
            onTap: () => _handleAction(
              context,
              ref,
              () => ref
                  .read(scannerViewModelProvider.notifier)
                  .analyzeImageFromCamera(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blueGrey),
            title: Text(l10n.imageFromGallery),
            onTap: () => _handleAction(
              context,
              ref,
              () => ref
                  .read(scannerViewModelProvider.notifier)
                  .analyzeImageFromGallery(),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.blueGrey,
            ),
            title: Text(l10n.imageFromPdf),
            onTap: () => _handleAction(
              context,
              ref,
              () => ref
                  .read(scannerViewModelProvider.notifier)
                  .analyzeImageFromPDF(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    final container = ProviderScope.containerOf(context);

    navigator.pop();

    await action();

    final state = container.read(scannerViewModelProvider);

    if (state.hasError) {
      _showErrorSnackBar(messenger, theme, state.error!, l10n);
      return;
    }

    final result = state.value;

    if (result == null || result.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noAvailableProducts)));
      return;
    }

    navigator.push(
      MaterialPageRoute(builder: (context) => const ReceiptEditPage()),
    );
  }

  void _showErrorSnackBar(
    ScaffoldMessengerState messenger,
    ThemeData theme,
    Object error,
    AppLocalizations l10n,
  ) {
    String message = error.toString();
    if (error is ReceiptAnalysisException) {
      if (error.code == 'INVALID_JSON' ||
          error.originalException is FormatException) {
        message = l10n.receiptReadErrorFormat;
      } else {
        message = error.message;
      }
    } else if (message.contains('FormatException')) {
      message = l10n.receiptReadErrorFormat;
    } else {
      message = '${l10n.errorOccurred}$message';
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }
}
