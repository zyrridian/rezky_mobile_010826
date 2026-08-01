import '../entities/stock_in_entity.dart';

abstract class StockInRepository {
  Future<List<StockInEntity>> getStockIns();
  Future<void> addStockIn(DateTime date, int itemId, int quantity, String remarks);
}
