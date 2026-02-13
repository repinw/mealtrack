import 'package:flutter/material.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_header.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ReceiptVerificationDialog extends StatelessWidget {
  final TextEditingController merchantController;
  final TextEditingController dateController;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onDateTap;
  final ValueChanged<String> onMerchantChanged;

  static const _confirmTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const _cancelTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );

  const ReceiptVerificationDialog({
    super.key,
    required this.merchantController,
    required this.dateController,
    required this.onConfirm,
    required this.onCancel,
    required this.onDateTap,
    required this.onMerchantChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final confirmButtonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    final cancelButtonStyle = TextButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      foregroundColor: colorScheme.onSurfaceVariant,
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReceiptHeader(
            merchantController: merchantController,
            dateController: dateController,
            onMerchantChanged: onMerchantChanged,
            onDateTap: onDateTap,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ElevatedButton(
                  style: confirmButtonStyle,
                  onPressed: onConfirm,
                  child: Text(l10n.confirm, style: _confirmTextStyle),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: cancelButtonStyle,
                  onPressed: onCancel,
                  child: Text(l10n.cancel, style: _cancelTextStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
