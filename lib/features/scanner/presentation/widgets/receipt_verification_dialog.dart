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

  static final _confirmButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    minimumSize: const Size.fromHeight(56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static final _cancelButtonStyle = TextButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    foregroundColor: Colors.white70,
  );

  static const _confirmTextStyle = TextStyle(
    color: Colors.white,
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

    return Dialog(
      backgroundColor: Colors.transparent,
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
                  style: _confirmButtonStyle,
                  onPressed: onConfirm,
                  child: Text(l10n.confirm, style: _confirmTextStyle),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: _cancelButtonStyle,
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
