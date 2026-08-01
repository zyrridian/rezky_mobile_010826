import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_controller.dart';
import '../../../auth/presentation/providers/login_controller.dart';
import '../../../auth/presentation/providers/login_state.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemControllerProvider.notifier).fetchItems());
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemControllerProvider);
    final authState = ref.watch(loginControllerProvider);
    
    bool isAdmin = false;
    if (authState is AuthSuccess) {
      isAdmin = authState.user.role == 'admin';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Master Barang')),
      body: _buildBody(itemState),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_item');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(ItemState state) {
    if (state is ItemLoading || state is ItemInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ItemError) {
      return Center(child: Text('Error: ${state.message}'));
    } else if (state is ItemLoaded) {
      if (state.items.isEmpty) {
        return const Center(child: Text('Belum ada barang.'));
      }
      return ListView.builder(
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return ListTile(
            title: Text('${item.name} (${item.sku})'),
            subtitle: Text('Kategori: ${item.category} | Satuan: ${item.unit}'),
            trailing: Chip(
              label: Text('Stok: ${item.currentStock}'),
              backgroundColor: item.currentStock > 0 ? Colors.green.shade100 : Colors.red.shade100,
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
