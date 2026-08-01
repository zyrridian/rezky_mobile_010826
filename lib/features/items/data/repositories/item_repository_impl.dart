import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/local/item_local_datasource.dart';
import '../datasources/remote/item_remote_datasource.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemLocalDataSource localDataSource;
  final ItemRemoteDataSource remoteDataSource;

  ItemRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<ItemEntity>> getItems() async {
    return await localDataSource.getItemsWithStock();
  }

  @override
  Future<ItemEntity> addItem(String sku, String name, String category, String unit) async {
    await remoteDataSource.syncItem();
    return await localDataSource.insertItem(sku, name, category, unit);
  }
}
