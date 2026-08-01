import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class GetItemsUseCase {
  final ItemRepository repository;
  GetItemsUseCase(this.repository);

  Future<List<ItemEntity>> execute({String query = ''}) {
    return repository.getItems(query: query);
  }
}

class AddItemUseCase {
  final ItemRepository repository;
  AddItemUseCase(this.repository);

  Future<ItemEntity> execute(String sku, String name, String category, String unit) {
    return repository.addItem(sku, name, category, unit);
  }
}
