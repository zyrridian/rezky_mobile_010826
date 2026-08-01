import '../entities/item_entity.dart';

abstract class ItemRepository {
  Future<List<ItemEntity>> getItems({String query = ''});
  Future<ItemEntity> addItem(String sku, String name, String category, String unit);
}
