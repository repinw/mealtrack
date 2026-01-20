import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/router/app_router.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/service/share_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ShareIntentListener extends ConsumerStatefulWidget {
  final Widget child;

  const ShareIntentListener({super.key, required this.child});

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  bool _isHandlingIntent = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(shareServiceProvider);

    ref.listen<XFile?>(latestSharedFileProvider, (_, next) async {
      if (next != null && !_isHandlingIntent) {
        setState(() => _isHandlingIntent = true);

        try {
          final navigatorContext = ref
              .read(navigatorKeyProvider)
              .currentContext;
          if (navigatorContext == null || !navigatorContext.mounted) {
            setState(() => _isHandlingIntent = false);
            return;
          }

          ref.read(latestSharedFileProvider.notifier).consume();

          final shouldScan = await _showConfirmationDialog(navigatorContext);

          if (shouldScan == true && mounted) {
            final processContext = ref
                .read(navigatorKeyProvider)
                .currentContext;
            if (processContext != null && processContext.mounted) {
              await _processSharedFile(processContext, next);
            }
          }
        } finally {
          if (mounted) {
            setState(() => _isHandlingIntent = false);
          }
        }
      }
    });

    return widget.child;
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

  Future<void> _processSharedFile(BuildContext context, XFile file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(scannerViewModelProvider.notifier).analyzeSharedFile(file);

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ReceiptEditPage()));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        debugPrint('Error analyzing shared file: $e');

        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.receiptReadErrorFormat ?? 'Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
