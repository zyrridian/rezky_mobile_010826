import '../../../../../core/database/app_database.dart';
import '../../models/stock_out_model.dart';

class StockOutLocalDataSource {
  final AppDatabase appDatabase;

  StockOutLocalDataSource(this.appDatabase);

  Future<List<StockOutModel>> getStockOuts() async {
    final db = await appDatabase.database;
    final query = '''
      SELECT stock_outs.*, items.name as itemName 
      FROM stock_outs 
      INNER JOIN items ON stock_outs.item_id = items.id
      ORDER BY stock_outs.date DESC
    ''';
    
    final result = await db.rawQuery(query);

    return result.map((row) {
      return StockOutModel(
        id: row['id'] as int,
        date: DateTime.parse(row['date'] as String),
        itemId: row['item_id'] as int,
        itemName: row['itemName'] as String,
        quantity: row['quantity'] as int,
        destination: row['destination'] as String?,
      );
    }).toList();
  }

  Future<void> insertStockOut(DateTime date, int itemId, int quantity, String destination) async {
    final db = await appDatabase.database;
    await db.insert('stock_outs', {
      'date': date.toIso8601String(),
      'item_id': itemId,
      'quantity': quantity,
      'destination': destination,
    });
  }
}
