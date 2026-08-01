import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/stock_out_local_datasource.dart';
import '../../data/datasources/remote/stock_out_remote_datasource.dart';
import '../../data/repositories/stock_out_repository_impl.dart';
import '../../domain/entities/stock_out_entity.dart';
import '../../domain/usecases/stock_out_usecases.dart';
import '../../../auth/presentation/providers/login_controller.dart'; 
import '../../../items/presentation/providers/item_controller.dart'; 
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;

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

  Future<String?> exportCsv() async {
    if (state is StockOutLoaded) {
      final items = (state as StockOutLoaded).data;
      List<List<dynamic>> rows = [
        ['Tanggal', 'Barang', 'Jumlah', 'Tujuan']
      ];
      for (var item in items) {
        rows.add([item.date.toIso8601String(), item.itemName, item.quantity, item.destination ?? '']);
      }
      String csv = const ListToCsvConverter().convert(rows);
      
      if (kIsWeb) {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'stock_out_report.csv';
        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        return 'WEB_DOWNLOADED';
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/stock_out_report.csv';
      final file = File(path);
      await file.writeAsString(csv);
      return path;
    }
    return null;
  }
}

final stockOutControllerProvider = NotifierProvider<StockOutController, StockOutState>(StockOutController.new);
