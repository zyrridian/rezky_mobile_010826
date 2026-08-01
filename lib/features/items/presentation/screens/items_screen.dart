import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../providers/item_controller.dart';
import '../../../auth/presentation/providers/login_controller.dart';
import '../../../auth/presentation/providers/login_state.dart';
import 'edit_item_screen.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemControllerProvider.notifier).fetchItems());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: _buildBody(itemState, isAdmin),
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

  Widget _buildBody(ItemState state, bool isAdmin) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by SKU or Name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(itemControllerProvider.notifier).fetchItems(query: value);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, size: 36),
                onPressed: () async {
                  var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ),
                  );
                  if (res is String && res != '-1') {
                    _searchController.text = res;
                    ref.read(itemControllerProvider.notifier).fetchItems(query: res);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(child: _buildList(state, isAdmin)),
      ],
    );
  }

  Widget _buildList(ItemState state, bool isAdmin) {
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
            onTap: isAdmin ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditItemScreen(item: item)),
              );
            } : null,
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
