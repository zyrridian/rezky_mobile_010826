import '../entities/stock_in_entity.dart';
import '../repositories/stock_in_repository.dart';

class GetStockInsUseCase {
  final StockInRepository repository;
  GetStockInsUseCase(this.repository);
  Future<List<StockInEntity>> execute() => repository.getStockIns();
}

class AddStockInUseCase {
  final StockInRepository repository;
  AddStockInUseCase(this.repository);
  Future<void> execute(DateTime date, int itemId, int quantity, String remarks) {
    return repository.addStockIn(date, itemId, quantity, remarks);
  }
}
