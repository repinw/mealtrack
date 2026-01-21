import 'package:flutter/material.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_header.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ReceiptVerificationDialog extends StatelessWidget {
  final TextEditingController merchantController;
  final TextEditingController dateController;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onDateTap;
  final ValueChanged<String> onMerchantChanged;

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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'receipt_header',
            child: Material(
              color: Colors.transparent,
              child: ReceiptHeader(
                merchantController: merchantController,
                dateController: dateController,
                onMerchantChanged: onMerchantChanged,
                onDateTap: onDateTap,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onConfirm,
                  child: Text(
                    l10n.confirm,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: Colors.white70,
                  ),
                  onPressed: onCancel,
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
