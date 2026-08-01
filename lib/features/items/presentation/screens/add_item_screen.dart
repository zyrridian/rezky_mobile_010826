import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_controller.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitController = TextEditingController();

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
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _skuController, decoration: const InputDecoration(labelText: 'SKU (Unik)')),
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
                        if (_skuController.text.isEmpty || _nameController.text.isEmpty) return;
                        ref.read(itemControllerProvider.notifier).addItem(
                          _skuController.text.trim(),
                          _nameController.text.trim(),
                          _categoryController.text.trim(),
                          _unitController.text.trim(),
                        );
                      },
                child: itemState is ItemLoading ? const CircularProgressIndicator() : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
