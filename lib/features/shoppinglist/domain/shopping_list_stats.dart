class ShoppingListStats {
  final double totalValue;
  final int scanCount;
  final int articleCount;

  const ShoppingListStats({
    required this.totalValue,
    required this.scanCount,
    required this.articleCount,
  });

  static const empty = ShoppingListStats(
    totalValue: 0,
    scanCount: 0,
    articleCount: 0,
  );
}
