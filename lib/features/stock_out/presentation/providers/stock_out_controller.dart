import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/stock_out_local_datasource.dart';
import '../../data/datasources/remote/stock_out_remote_datasource.dart';
import '../../data/repositories/stock_out_repository_impl.dart';
import '../../domain/entities/stock_out_entity.dart';
import '../../domain/usecases/stock_out_usecases.dart';
import '../../../auth/presentation/providers/login_controller.dart'; 
import '../../../items/presentation/providers/item_controller.dart'; 

final stockOutLocalDataSourceProvider = Provider((ref) {
  return StockOutLocalDataSource(ref.watch(databaseProvider));
});

final stockOutRemoteDataSourceProvider = Provider((ref) {
  return StockOutRemoteDataSource();
});

final stockOutRepositoryProvider = Provider((ref) {
  return StockOutRepositoryImpl(
    localDataSource: ref.watch(stockOutLocalDataSourceProvider),
    remoteDataSource: ref.watch(stockOutRemoteDataSourceProvider),
  );
});

final getStockOutsUseCaseProvider = Provider((ref) => GetStockOutsUseCase(ref.watch(stockOutRepositoryProvider)));
final addStockOutUseCaseProvider = Provider((ref) => AddStockOutUseCase(ref.watch(stockOutRepositoryProvider)));

abstract class StockOutState {}
class StockOutInitial extends StockOutState {}
class StockOutLoading extends StockOutState {}
class StockOutLoaded extends StockOutState {
  final List<StockOutEntity> data;
  StockOutLoaded(this.data);
}
class StockOutError extends StockOutState {
  final String message;
  StockOutError(this.message);
}

class StockOutController extends Notifier<StockOutState> {
  @override
  StockOutState build() {
    return StockOutInitial();
  }

  Future<void> fetchStockOuts() async {
    state = StockOutLoading();
    try {
      final data = await ref.read(getStockOutsUseCaseProvider).execute();
      state = StockOutLoaded(data);
    } catch (e) {
      state = StockOutError(e.toString());
    }
  }

  Future<void> addStockOut(DateTime date, int itemId, int quantity, String destination) async {
    state = StockOutLoading();
    try {
      await ref.read(addStockOutUseCaseProvider).execute(date, itemId, quantity, destination);
      // Refresh both stock out history and global items stock
      await fetchStockOuts();
      await ref.read(itemControllerProvider.notifier).fetchItems();
    } catch (e) {
      state = StockOutError(e.toString());
    }
  }
}

final stockOutControllerProvider = NotifierProvider<StockOutController, StockOutState>(StockOutController.new);
