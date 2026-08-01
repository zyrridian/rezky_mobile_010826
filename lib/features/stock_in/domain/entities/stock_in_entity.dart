class StockInEntity {
  final int id;
  final DateTime date;
  final int itemId;
  final String itemName;
  final int quantity;
  final String? remarks;

  StockInEntity({
    required this.id,
    required this.date,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    this.remarks,
  });
}
