import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

String formatInventoryAmount(double value) {
  if ((value - value.roundToDouble()).abs() < 0.0001) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

class InventoryAmountPickerDialog extends StatefulWidget {
  final FridgeItem item;
  final String actionLabel;

  const InventoryAmountPickerDialog({
    super.key,
    required this.item,
    required this.actionLabel,
  });

  static Future<double?> show(
    BuildContext context, {
    required FridgeItem item,
    required String actionLabel,
  }) {
    return showDialog<double>(
      context: context,
      builder: (dialogContext) =>
          InventoryAmountPickerDialog(item: item, actionLabel: actionLabel),
    );
  }

  @override
  State<InventoryAmountPickerDialog> createState() =>
      InventoryAmountPickerDialogState();
}

class InventoryAmountPickerDialogState
    extends State<InventoryAmountPickerDialog> {
  late final TextEditingController amountController;
  String? errorText;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: formatInventoryAmount(widget.item.resolvedRemainingAmountBase),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  double get maxAmount => widget.item.resolvedRemainingAmountBase;

  void applyPreset(double amount) {
    amountController.text = formatInventoryAmount(amount);
    setState(() {
      errorText = null;
    });
  }

  void submit() {
    final parsed = double.tryParse(amountController.text.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0 || parsed > maxAmount) {
      setState(() {
        errorText =
            'Bitte einen Wert zwischen 0 und ${formatInventoryAmount(maxAmount)} eingeben';
      });
      return;
    }
    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unit = widget.item.resolvedAmountUnit.symbol;
    final pieceAmount = widget.item.amountPerPieceBase;
    final presets = <double>{
      if (pieceAmount > fridgeItemAmountEpsilon) pieceAmount,
      maxAmount / 2,
      maxAmount,
    }.where((amount) => amount > 0 && amount <= maxAmount).toList()..sort();

    return AlertDialog(
      title: Text('${widget.actionLabel} - Menge'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verbleibend: ${formatInventoryAmount(maxAmount)} $unit'),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: 'Menge ($unit)',
              errorText: errorText,
            ),
            onSubmitted: (_) => submit(),
          ),
          if (presets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets
                  .map(
                    (preset) => ActionChip(
                      label: Text('${formatInventoryAmount(preset)} $unit'),
                      onPressed: () => applyPreset(preset),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: submit, child: Text(l10n.save)),
      ],
    );
  }
}
