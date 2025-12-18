import 'package:flutter/material.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';

class ScannedItemRow extends StatefulWidget {
  final ScannedItem item;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  // --- Layout Constants ---
  static const double colQtyWidth = 30;
  static const double colWeightWidth = 55;
  static const double colPriceWidth = 110; // Space for price, €, icon & delete

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
  late TextEditingController _priceController;
  late TextEditingController _qtyController;
  late TextEditingController _weightController;

  double get _discountAmount {
    return widget.item.discounts?.fold(0.0, (sum, d) => sum! + d.amount) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with item values
    _nameController = TextEditingController(text: widget.item.name);
    // Display price minus discount
    _priceController = TextEditingController(
      text: (widget.item.totalPrice - _discountAmount).toStringAsFixed(2),
    );
    _qtyController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _weightController = TextEditingController(text: widget.item.weight ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onQtyChanged(String value) {
    final newQty = int.tryParse(value);
    if (newQty == null) return;

    double unitPrice = widget.item.unitPrice ?? 0.0;
    // Fallback: Calculate unit price if missing or 0
    if (unitPrice == 0.0 && widget.item.quantity > 0) {
      unitPrice = widget.item.totalPrice / widget.item.quantity;
    }

    final newGrossTotal = unitPrice * newQty;
    final newDisplayedPrice = newGrossTotal - _discountAmount;

    _priceController.text = newDisplayedPrice.toStringAsFixed(2);
    _updateItem();
  }

  void _updateItem() {
    // Write values from controllers back to item
    final name = _nameController.text;
    final qty = int.tryParse(_qtyController.text);
    final weight = _weightController.text;

    // Logic: Allow input of total price
    final displayedPrice =
        double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;

    // Save gross price (displayed price + discount)
    final grossTotalPrice = displayedPrice + _discountAmount;

    // Update item
    widget.item.name = name;
    widget.item.weight = weight.isEmpty ? null : weight;
    widget.item.isLowConfidence = false; // Mark as verified upon edit

    if (qty != null) {
      // Optional: Recalculate unit price
      final unitPrice = qty > 0 ? grossTotalPrice / qty : grossTotalPrice;

      widget.item.quantity = qty;
      widget.item.totalPrice = grossTotalPrice;
      widget.item.unitPrice = unitPrice;
    }

    // Notify parent to recalculate total
    widget.onChanged();
  }

  void _showDiscounts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enthaltene Rabatte"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.item.discounts!.map((d) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d.name),
                Text(
                  "-${d.amount.toStringAsFixed(2)} €",
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: GestureDetector(
        onTap: _discountAmount > 0 ? _showDiscounts : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: widget.item.isLowConfidence
                ? Border.all(color: Colors.amber, width: 1.5)
                : Border.all(color: Colors.transparent),
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
              // Quantity
              SizedBox(
                width: ScannedItemRow.colQtyWidth,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.indigo,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                  onChanged: _onQtyChanged,
                ),
              ),
              // Name
              Expanded(
                child: TextField(
                  controller: _nameController,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                    hintText: "Artikelname",
                  ),
                  onChanged: (_) =>
                      _updateItem(), // Important: onChanged update
                ),
              ),

              const SizedBox(width: 12),

              // Weight
              SizedBox(
                width: ScannedItemRow.colWeightWidth,
                child: TextField(
                  controller: _weightController,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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

              // Price
              SizedBox(
                width: ScannedItemRow.colPriceWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_discountAmount > 0)
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
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
                    const Text(
                      " €",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
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
      ),
    );
  }
}
