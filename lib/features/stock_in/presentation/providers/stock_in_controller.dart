import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/stock_in_local_datasource.dart';
import '../../data/datasources/remote/stock_in_remote_datasource.dart';
import '../../data/repositories/stock_in_repository_impl.dart';
import '../../domain/entities/stock_in_entity.dart';
import '../../domain/usecases/stock_in_usecases.dart';
import '../../../auth/presentation/providers/login_controller.dart'; 
import '../../../items/presentation/providers/item_controller.dart'; 
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;

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

  Future<String?> exportCsv() async {
    if (state is StockInLoaded) {
      final items = (state as StockInLoaded).data;
      List<List<dynamic>> rows = [
        ['Tanggal', 'Barang', 'Jumlah', 'Keterangan']
      ];
      for (var item in items) {
        rows.add([item.date.toIso8601String(), item.itemName, item.quantity, item.remarks ?? '']);
      }
      String csv = const ListToCsvConverter().convert(rows);
      
      if (kIsWeb) {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'stock_in_report.csv';
        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        return 'WEB_DOWNLOADED';
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/stock_in_report.csv';
      final file = File(path);
      await file.writeAsString(csv);
      return path;
    }
    return null;
  }
}

final stockInControllerProvider = NotifierProvider<StockInController, StockInState>(StockInController.new);
