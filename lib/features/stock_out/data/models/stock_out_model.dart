import '../../domain/entities/stock_out_entity.dart';

class StockOutModel extends StockOutEntity {
  StockOutModel({
    required super.id,
    required super.date,
    required super.itemId,
    required super.itemName,
    required super.quantity,
    super.destination,
  });
}
