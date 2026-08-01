import '../entities/stock_out_entity.dart';
import '../repositories/stock_out_repository.dart';

class GetStockOutsUseCase {
  final StockOutRepository repository;
  GetStockOutsUseCase(this.repository);
  Future<List<StockOutEntity>> execute() => repository.getStockOuts();
}

class AddStockOutUseCase {
  final StockOutRepository repository;
  AddStockOutUseCase(this.repository);
  Future<void> execute(DateTime date, int itemId, int quantity, String destination) {
    return repository.addStockOut(date, itemId, quantity, destination);
  }
}
