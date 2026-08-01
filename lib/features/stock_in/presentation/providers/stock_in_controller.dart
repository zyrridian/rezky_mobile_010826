import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/stock_in_local_datasource.dart';
import '../../data/datasources/remote/stock_in_remote_datasource.dart';
import '../../data/repositories/stock_in_repository_impl.dart';
import '../../domain/entities/stock_in_entity.dart';
import '../../domain/usecases/stock_in_usecases.dart';
import '../../../auth/presentation/providers/login_controller.dart'; 
import '../../../items/presentation/providers/item_controller.dart'; 

final stockInLocalDataSourceProvider = Provider((ref) {
  return StockInLocalDataSource(ref.watch(databaseProvider));
});

final stockInRemoteDataSourceProvider = Provider((ref) {
  return StockInRemoteDataSource();
});

final stockInRepositoryProvider = Provider((ref) {
  return StockInRepositoryImpl(
    localDataSource: ref.watch(stockInLocalDataSourceProvider),
    remoteDataSource: ref.watch(stockInRemoteDataSourceProvider),
  );
});

final getStockInsUseCaseProvider = Provider((ref) => GetStockInsUseCase(ref.watch(stockInRepositoryProvider)));
final addStockInUseCaseProvider = Provider((ref) => AddStockInUseCase(ref.watch(stockInRepositoryProvider)));

abstract class StockInState {}
class StockInInitial extends StockInState {}
class StockInLoading extends StockInState {}
class StockInLoaded extends StockInState {
  final List<StockInEntity> data;
  StockInLoaded(this.data);
}
class StockInError extends StockInState {
  final String message;
  StockInError(this.message);
}

class StockInController extends Notifier<StockInState> {
  @override
  StockInState build() {
    return StockInInitial();
  }

  Future<void> fetchStockIns() async {
    state = StockInLoading();
    try {
      final data = await ref.read(getStockInsUseCaseProvider).execute();
      state = StockInLoaded(data);
    } catch (e) {
      state = StockInError(e.toString());
    }
  }

  Future<void> addStockIn(DateTime date, int itemId, int quantity, String remarks) async {
    state = StockInLoading();
    try {
      await ref.read(addStockInUseCaseProvider).execute(date, itemId, quantity, remarks);
      // Refresh both stock in history and global items stock
      await fetchStockIns();
      await ref.read(itemControllerProvider.notifier).fetchItems();
    } catch (e) {
      state = StockInError(e.toString());
    }
  }
}

final stockInControllerProvider = NotifierProvider<StockInController, StockInState>(StockInController.new);
