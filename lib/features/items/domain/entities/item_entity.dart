class ItemEntity {
  final int id;
  final String sku;
  final String name;
  final String category;
  final String unit;
  final int currentStock;

  ItemEntity({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
  });
}
