import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/item_local_datasource.dart';
import '../../data/datasources/remote/item_remote_datasource.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/usecases/item_usecases.dart';
import '../../../auth/presentation/providers/login_controller.dart'; // To access databaseProvider

final itemLocalDataSourceProvider = Provider((ref) {
  return ItemLocalDataSource(ref.watch(databaseProvider));
});

final itemRemoteDataSourceProvider = Provider((ref) {
  return ItemRemoteDataSource();
});

final itemRepositoryProvider = Provider((ref) {
  return ItemRepositoryImpl(
    localDataSource: ref.watch(itemLocalDataSourceProvider),
    remoteDataSource: ref.watch(itemRemoteDataSourceProvider),
  );
});

final getItemsUseCaseProvider = Provider((ref) => GetItemsUseCase(ref.watch(itemRepositoryProvider)));
final addItemUseCaseProvider = Provider((ref) => AddItemUseCase(ref.watch(itemRepositoryProvider)));
final updateItemUseCaseProvider = Provider((ref) => UpdateItemUseCase(ref.watch(itemRepositoryProvider)));
final deleteItemUseCaseProvider = Provider((ref) => DeleteItemUseCase(ref.watch(itemRepositoryProvider)));

abstract class ItemState {}
class ItemInitial extends ItemState {}
class ItemLoading extends ItemState {}
class ItemLoaded extends ItemState {
  final List<ItemEntity> items;
  ItemLoaded(this.items);
}
class ItemError extends ItemState {
  final String message;
  ItemError(this.message);
}

class ItemController extends Notifier<ItemState> {
  @override
  ItemState build() {
    return ItemInitial();
  }

  Future<void> fetchItems({String query = ''}) async {
    state = ItemLoading();
    try {
      final items = await ref.read(getItemsUseCaseProvider).execute(query: query);
      state = ItemLoaded(items);
    } catch (e) {
      state = ItemError(e.toString());
    }
  }

  Future<void> addItem(String sku, String name, String category, String unit) async {
    state = ItemLoading();
    try {
      await ref.read(addItemUseCaseProvider).execute(sku, name, category, unit);
      await fetchItems();
    } catch (e) {
      state = ItemError(e.toString());
    }
  }

  Future<void> updateItem(int id, String name, String category, String unit) async {
    state = ItemLoading();
    try {
      await ref.read(updateItemUseCaseProvider).execute(id, name, category, unit);
      await fetchItems();
    } catch (e) {
      state = ItemError(e.toString());
    }
  }

  Future<void> deleteItem(int id) async {
    state = ItemLoading();
    try {
      await ref.read(deleteItemUseCaseProvider).execute(id);
      await fetchItems();
    } catch (e) {
      state = ItemError(e.toString());
      // Re-fetch to clear error state eventually or handle it in UI
      await Future.delayed(const Duration(seconds: 2));
      await fetchItems();
    }
  }
}

final itemControllerProvider = NotifierProvider<ItemController, ItemState>(ItemController.new);
