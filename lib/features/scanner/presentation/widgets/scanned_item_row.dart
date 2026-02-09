import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class ScannedItemRow extends StatefulWidget {
  final FridgeItem item;
  final VoidCallback onDelete;
  final ValueChanged<FridgeItem> onChanged;

  static const double colQtyWidth = 30;
  static const double colWeightWidth = 55;
  static const double colPriceWidth = 120;

  const ScannedItemRow({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<ScannedItemRow> createState() => _ScannedItemRowState();
}

class _ScannedItemRowState extends State<ScannedItemRow> {
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;
  late TextEditingController _weightController;

  String? _cachedLocale;
  late NumberFormat _decimalFormat;
  late NumberFormat _currencyFormat;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _brandController = TextEditingController(text: widget.item.brand ?? '');
    _priceController = TextEditingController();
    _qtyController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _weightController = TextEditingController(text: widget.item.weight ?? '');
  }

  String _getLocale() {
    return widget.item.language ?? Localizations.localeOf(context).toString();
  }

  void _updateNumberFormats() {
    final locale = _getLocale();
    if (_cachedLocale != locale) {
      _cachedLocale = locale;
      _decimalFormat = NumberFormat.decimalPattern(locale)
        ..minimumFractionDigits = 2
        ..maximumFractionDigits = 2;
      _currencyFormat = NumberFormat.simpleCurrency(
        locale: locale,
        name: 'EUR',
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNumberFormats();
    final total = widget.item.unitPrice * widget.item.quantity;
    final priceText = _decimalFormat.format(total);

    double? currentPriceVal;
    try {
      currentPriceVal = _decimalFormat.parse(_priceController.text).toDouble();
    } catch (_) {
      currentPriceVal = null;
    }

    if (currentPriceVal != total) {
      _priceController.text = priceText;
    }
  }

  @override
  void didUpdateWidget(ScannedItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
      if (_nameController.text != widget.item.name) {
        _nameController.text = widget.item.name;
      }

      final total = widget.item.unitPrice * widget.item.quantity;
      final priceText = _decimalFormat.format(total);

      double? currentPriceVal;
      try {
        currentPriceVal = _decimalFormat
            .parse(_priceController.text)
            .toDouble();
      } catch (_) {
        currentPriceVal = null;
      }

      if (currentPriceVal != total) {
        _priceController.text = priceText;
      }
      if (_qtyController.text != widget.item.quantity.toString()) {
        _qtyController.text = widget.item.quantity.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onQtyChanged(String value) {
    final newQty = int.tryParse(value);
    if (newQty == null) return;

    _updateItem();
  }

  void _showDiscounts() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.includedDiscounts),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.item.discounts.entries.map((entry) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key),
                Text(
                  "-${_currencyFormat.format(entry.value)}",
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _updateItem() {
    final weightText = _weightController.text;
    final brandText = _brandController.text;

    var quantity = int.tryParse(_qtyController.text) ?? widget.item.quantity;
    if (quantity < 1) quantity = 1;

    double totalPrice = 0.0;
    try {
      totalPrice = _decimalFormat.parse(_priceController.text).toDouble();
    } catch (_) {
      // Fallback to 0.0 if parsing fails
    }

    final unitPrice = quantity > 0 ? totalPrice / quantity : 0.0;

    final newItem = widget.item.copyWith(
      name: _nameController.text,
      weight: weightText.isNotEmpty ? weightText : null,
      brand: brandText.isNotEmpty ? brandText : null,
      unitPrice: unitPrice,
      quantity: quantity,
    );

    widget.onChanged(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: ScannedItemRow.colQtyWidth,
              child: TextField(
                key: const Key('quantityField'),
                controller: _qtyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: widget.item.isDeposit ? Colors.grey : Colors.indigo,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                ),
                onChanged: _onQtyChanged,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    key: const Key('brandField'),
                    controller: _brandController,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: l10n.brandHint,
                    ),
                    onChanged: (_) => _updateItem(),
                  ),
                  TextField(
                    key: const Key('nameField'),
                    controller: _nameController,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: widget.item.isDeposit ? Colors.grey : Colors.black,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.only(bottom: 2),
                      border: InputBorder.none,
                      hintText: l10n.itemNameHint,
                    ),
                    onChanged: (_) => _updateItem(),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              width: ScannedItemRow.colWeightWidth,
              child: TextField(
                key: const Key('weightField'),
                controller: _weightController,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: widget.item.isDeposit ? Colors.grey : Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                  hintText: "-",
                ),
                onChanged: (_) => _updateItem(),
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              width: ScannedItemRow.colPriceWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.item.discounts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: GestureDetector(
                        onTap: _showDiscounts,
                        child: const Icon(
                          Icons.local_offer,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 45,
                    child: TextField(
                      key: const Key('priceField'),
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: widget.item.isDeposit
                            ? Colors.grey
                            : Colors.black,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                        hintText: "0.00",
                      ),
                      onChanged: (_) => _updateItem(),
                    ),
                  ),
                  Text(
                    " ${_currencyFormat.currencySymbol}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
