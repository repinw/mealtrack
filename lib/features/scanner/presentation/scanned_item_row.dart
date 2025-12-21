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
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with item values
    _nameController = TextEditingController(text: widget.item.name);
    _brandController = TextEditingController(text: widget.item.brand ?? '');
    // Display price minus discount
    _priceController = TextEditingController(
      text: widget.item.effectivePrice.toStringAsFixed(2),
    );
    _qtyController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _weightController = TextEditingController(text: widget.item.weight ?? '');
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

    final newDisplayedPrice = widget.item.calculateEffectivePriceForQuantity(
      newQty,
    );

    _priceController.text = newDisplayedPrice.toStringAsFixed(2);
    _updateItem();
  }

  void _updateItem() {
    widget.item.updateFromUser(
      name: _nameController.text,
      weight: _weightController.text.isEmpty ? null : _weightController.text,
      brand: _brandController.text,
      displayedPrice:
          double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      quantity: int.tryParse(_qtyController.text) ?? widget.item.quantity,
    );

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
          children: widget.item.discounts.entries.map((entry) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key),
                Text(
                  "-${entry.value.toStringAsFixed(2)} €",
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
        onTap: widget.item.totalDiscount > 0 ? _showDiscounts : null,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _brandController,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: "Marke",
                      ),
                      onChanged: (_) => _updateItem(),
                    ),
                    TextField(
                      controller: _nameController,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 2),
                        border: InputBorder.none,
                        hintText: "Artikelname",
                      ),
                      onChanged: (_) => _updateItem(),
                    ),
                  ],
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
                    if (widget.item.totalDiscount > 0)
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
