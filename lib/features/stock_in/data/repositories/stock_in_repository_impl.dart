import '../../domain/entities/stock_in_entity.dart';
import '../../domain/repositories/stock_in_repository.dart';
import '../datasources/local/stock_in_local_datasource.dart';
import '../datasources/remote/stock_in_remote_datasource.dart';

class StockInRepositoryImpl implements StockInRepository {
  final StockInLocalDataSource localDataSource;
  final StockInRemoteDataSource remoteDataSource;

  StockInRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<StockInEntity>> getStockIns() async {
    return await localDataSource.getStockIns();
  }

  @override
  Future<void> addStockIn(DateTime date, int itemId, int quantity, String remarks) async {
    await remoteDataSource.syncStockIn();
    await localDataSource.insertStockIn(date, itemId, quantity, remarks);
  }
}
