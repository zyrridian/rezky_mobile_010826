import '../../domain/entities/stock_out_entity.dart';
import '../../domain/repositories/stock_out_repository.dart';
import '../datasources/local/stock_out_local_datasource.dart';
import '../datasources/remote/stock_out_remote_datasource.dart';

class StockOutRepositoryImpl implements StockOutRepository {
  final StockOutLocalDataSource localDataSource;
  final StockOutRemoteDataSource remoteDataSource;

  StockOutRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<StockOutEntity>> getStockOuts() async {
    return await localDataSource.getStockOuts();
  }

  @override
  Future<void> addStockOut(DateTime date, int itemId, int quantity, String destination) async {
    await remoteDataSource.syncStockOut();
    await localDataSource.insertStockOut(date, itemId, quantity, destination);
  }
}
