import '../entities/stock_out_entity.dart';

abstract class StockOutRepository {
  Future<List<StockOutEntity>> getStockOuts();
  Future<void> addStockOut(DateTime date, int itemId, int quantity, String destination);
}
