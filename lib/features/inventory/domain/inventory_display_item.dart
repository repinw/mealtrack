import 'package:equatable/equatable.dart';

sealed class InventoryDisplayItem extends Equatable {
  const InventoryDisplayItem();
}

class InventoryHeaderItem extends InventoryDisplayItem {
  final String storeName;
  final DateTime entryDate;
  final int itemCount;
  final String receiptId;
  final bool isFullyConsumed;
  final bool isArchived;
  final bool isCollapsed;

  const InventoryHeaderItem({
    required this.storeName,
    required this.entryDate,
    required this.itemCount,
    required this.receiptId,
    required this.isFullyConsumed,
    this.isArchived = false,
    this.isCollapsed = false,
  });

  @override
  List<Object?> get props => [
    storeName,
    entryDate,
    itemCount,
    receiptId,
    isFullyConsumed,
    isArchived,
    isCollapsed,
  ];
}

class InventoryProductItem extends InventoryDisplayItem {
  final String itemId;
  const InventoryProductItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class InventorySpacerItem extends InventoryDisplayItem {
  const InventorySpacerItem();

  @override
  List<Object?> get props => [];
}

class InventoryArchivedSectionItem extends InventoryDisplayItem {
  final int archivedReceiptCount;
  final bool isExpanded;

  const InventoryArchivedSectionItem({
    required this.archivedReceiptCount,
    required this.isExpanded,
  });

  @override
  List<Object?> get props => [archivedReceiptCount, isExpanded];
}
