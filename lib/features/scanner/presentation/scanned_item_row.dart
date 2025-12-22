import 'package:flutter/material.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

class ScannedItemRow extends StatefulWidget {
  final FridgeItem item;
  final VoidCallback onDelete;
  final ValueChanged<FridgeItem> onChanged;

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
    _nameController = TextEditingController(text: widget.item.rawText);
    _brandController = TextEditingController(text: widget.item.brand ?? '');
    // Display price minus discount
    _priceController = TextEditingController(
      text: (widget.item.unitPrice ?? 0.0).toStringAsFixed(2),
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

    _updateItem();
  }

  void _updateItem() {
    final newItem = widget.item.copyWith(
      rawText: _nameController.text,
      weight: _weightController.text.isEmpty ? null : _weightController.text,
      brand: _brandController.text,
      unitPrice:
          double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      quantity: int.tryParse(_qtyController.text) ?? widget.item.quantity,
    );

    // Notify parent to recalculate total
    widget.onChanged(newItem);
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
