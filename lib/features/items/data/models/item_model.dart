import '../../domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  ItemModel({
    required super.id,
    required super.sku,
    required super.name,
    required super.category,
    required super.unit,
    required super.currentStock,
  });

  factory ItemModel.fromEntity(ItemEntity entity) {
    return ItemModel(
      id: entity.id,
      sku: entity.sku,
      name: entity.name,
      category: entity.category,
      unit: entity.unit,
      currentStock: entity.currentStock,
    );
  }
}
