import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/router/app_router.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/service/share_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ShareIntentListener extends ConsumerWidget {
  final Widget child;

  const ShareIntentListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(shareServiceProvider);

    ref.listen<XFile?>(latestSharedFileProvider, (_, next) async {
      if (next != null) {
        ref.read(latestSharedFileProvider.notifier).consume();

        final navigatorContext = rootNavigatorKey.currentContext;
        if (navigatorContext == null) return;

        final shouldScan = await _showConfirmationDialog(navigatorContext);
        if (shouldScan != true) return;

        // Check if context is still valid
        if (rootNavigatorKey.currentContext == null) return;

        await _processSharedFile(ref, next);
      }
    });

    return child;
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.scanReceiptDialogTitle),
        content: Text(l10n.scanReceiptDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }

  Future<void> _processSharedFile(WidgetRef ref, XFile file) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(scannerViewModelProvider.notifier).analyzeSharedFile(file);

      // Pop loading dialog
      rootNavigatorKey.currentState?.pop();
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const ReceiptEditPage()),
      );
    } catch (e) {
      // Pop loading dialog
      rootNavigatorKey.currentState?.pop();
      debugPrint('Error analyzing shared file: $e');
    }
  }
}
