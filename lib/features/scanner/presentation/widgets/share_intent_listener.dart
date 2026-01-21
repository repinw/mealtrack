import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/router/app_router.dart';
import 'package:mealtrack/features/scanner/presentation/controller/share_flow_controller.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scan_confirmation_dialog.dart';
import 'package:mealtrack/features/scanner/service/share_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ShareIntentListener extends ConsumerWidget {
  final Widget child;

  const ShareIntentListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(shareServiceProvider);

    ref.watch(shareFlowControllerProvider);

    ref.listen(shareFlowControllerProvider, (previous, next) async {
      final navigatorContext = ref.read(navigatorKeyProvider).currentContext;
      if (navigatorContext == null || !navigatorContext.mounted) return;

      await next.map(
        initial: (_) {},
        confirmationPending: (state) async {
          final shouldScan = await ScanConfirmationDialog.show(
            navigatorContext,
          );
          if (navigatorContext.mounted) {
            if (shouldScan == true) {
              ref.read(shareFlowControllerProvider.notifier).confirmScan();
            } else {
              ref.read(shareFlowControllerProvider.notifier).cancelScan();
            }
          }
        },
        analyzing: (_) async {
          showDialog(
            context: navigatorContext,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator()),
          );
        },
        success: (_) {
          if (Navigator.canPop(navigatorContext)) {
            Navigator.pop(navigatorContext);
          }

          Navigator.push(
            navigatorContext,
            MaterialPageRoute(builder: (_) => const ReceiptEditPage()),
          );

          ref.read(shareFlowControllerProvider.notifier).successHandled();
        },
        error: (state) {
          if (Navigator.canPop(navigatorContext)) {
            Navigator.pop(navigatorContext);
          }

          final l10n = AppLocalizations.of(navigatorContext);
          ScaffoldMessenger.of(navigatorContext).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.receiptReadErrorFormat ?? 'Error: ${state.error}',
              ),
              backgroundColor: Theme.of(navigatorContext).colorScheme.error,
            ),
          );

          ref.read(shareFlowControllerProvider.notifier).errorHandled();
        },
      );
    });

    return child;
  }
}
