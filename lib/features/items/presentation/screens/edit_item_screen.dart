import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_controller.dart';
import '../../domain/entities/item_entity.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final ItemEntity item;

  const EditItemScreen({super.key, required this.item});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  late TextEditingController _skuController;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController(text: widget.item.sku);
    _nameController = TextEditingController(text: widget.item.name);
    _categoryController = TextEditingController(text: widget.item.category);
    _unitController = TextEditingController(text: widget.item.unit);
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemControllerProvider);

    ref.listen<ItemState>(itemControllerProvider, (previous, next) {
      if (next is ItemError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message), backgroundColor: Colors.red));
      } else if (next is ItemLoaded && previous is ItemLoading) {
        Navigator.pop(context); // Go back after success
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Barang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _skuController,
              decoration: const InputDecoration(labelText: 'SKU (Locked)'),
              enabled: false, // Lock the SKU
            ),
            const SizedBox(height: 12),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Barang')),
            const SizedBox(height: 12),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Kategori')),
            const SizedBox(height: 12),
            TextField(controller: _unitController, decoration: const InputDecoration(labelText: 'Satuan')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: itemState is ItemLoading
                    ? null
                    : () {
                        if (_nameController.text.isEmpty) return;
                        ref.read(itemControllerProvider.notifier).updateItem(
                          widget.item.id,
                          _nameController.text.trim(),
                          _categoryController.text.trim(),
                          _unitController.text.trim(),
                        );
                      },
                child: itemState is ItemLoading ? const CircularProgressIndicator() : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang?'),
        content: const Text('Barang ini hanya bisa dihapus jika belum pernah ada transaksi masuk atau keluar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(itemControllerProvider.notifier).deleteItem(widget.item.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
