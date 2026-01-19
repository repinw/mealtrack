class InventoryStats {
  final double totalValue;
  final int scanCount;
  final int articleCount;

  const InventoryStats({
    required this.totalValue,
    required this.scanCount,
    required this.articleCount,
  });

  static const empty = InventoryStats(
    totalValue: 0,
    scanCount: 0,
    articleCount: 0,
  );
}
