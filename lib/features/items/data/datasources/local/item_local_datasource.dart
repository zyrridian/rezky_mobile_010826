import '../../../../../core/database/app_database.dart';
import '../../models/item_model.dart';

class ItemLocalDataSource {
  final AppDatabase appDatabase;

  ItemLocalDataSource(this.appDatabase);

  Future<List<ItemModel>> getItemsWithStock() async {
    final db = await appDatabase.database;
    final query = '''
      SELECT 
        items.id, items.sku, items.name, items.category, items.unit,
        COALESCE((SELECT SUM(quantity) FROM stock_ins WHERE item_id = items.id), 0) -
        COALESCE((SELECT SUM(quantity) FROM stock_outs WHERE item_id = items.id), 0) AS currentStock
      FROM items
    ''';
    
    final rows = await db.rawQuery(query);
    
    return rows.map((row) => ItemModel(
      id: row['id'] as int,
      sku: row['sku'] as String,
      name: row['name'] as String,
      category: row['category'] as String,
      unit: row['unit'] as String,
      currentStock: row['currentStock'] as int,
    )).toList();
  }

  Future<ItemModel> insertItem(String sku, String name, String category, String unit) async {
    final db = await appDatabase.database;
    
    final id = await db.insert('items', {
      'sku': sku,
      'name': name,
      'category': category,
      'unit': unit,
    });
    
    return ItemModel(
      id: id,
      sku: sku,
      name: name,
      category: category,
      unit: unit,
      currentStock: 0,
    );
  }
}
