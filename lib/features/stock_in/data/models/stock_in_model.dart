import '../../domain/entities/stock_in_entity.dart';

class StockInModel extends StockInEntity {
  StockInModel({
    required super.id,
    required super.date,
    required super.itemId,
    required super.itemName,
    required super.quantity,
    super.remarks,
  });
}
