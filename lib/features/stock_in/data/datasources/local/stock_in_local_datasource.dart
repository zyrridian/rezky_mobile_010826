import '../../../../../core/database/app_database.dart';
import '../../models/stock_in_model.dart';

class StockInLocalDataSource {
  final AppDatabase appDatabase;

  StockInLocalDataSource(this.appDatabase);

  Future<List<StockInModel>> getStockIns() async {
    final db = await appDatabase.database;
    final query = '''
      SELECT stock_ins.*, items.name as itemName 
      FROM stock_ins 
      INNER JOIN items ON stock_ins.item_id = items.id
      ORDER BY stock_ins.date DESC
    ''';
    
    final result = await db.rawQuery(query);

    return result.map((row) {
      return StockInModel(
        id: row['id'] as int,
        date: DateTime.parse(row['date'] as String),
        itemId: row['item_id'] as int,
        itemName: row['itemName'] as String,
        quantity: row['quantity'] as int,
        remarks: row['remarks'] as String?,
      );
    }).toList();
  }

  Future<void> insertStockIn(DateTime date, int itemId, int quantity, String remarks) async {
    final db = await appDatabase.database;
    await db.insert('stock_ins', {
      'date': date.toIso8601String(),
      'item_id': itemId,
      'quantity': quantity,
      'remarks': remarks,
    });
  }
}
